
-- =============================================
-- Author:		Alessandro Nostini

-- Create date: 2012-03-19
-- Modify date 2012-09-19: per traslazione id paziente nel paziente attivo
-- Modify date 2015-08-19: Usa le VIEW store
--							Invece di AllegatiBase usa Allegati che gestisce MineDataCompresso
--							Prestazioni e Referti usate per ottimizare accesso agli attributi
-- Modify date 2016-10-02: Rimuove gli attributi con NOME con caratteri parentesi
-- Modify date 2017-02-16: Rimuove l'attributo CONFIDENZIALE = NO perchè va in conflitto con l'ELEMENT (mappa di Marcod)
-------------------------------------------------------------
-- Create date: 2017-10-24: Rinominata
-- Modify date: 2018-02-14: Codifico il nome attributo con [dbo].[SoleNomeAttributoCodifica]()
--								Previene un problema di mappa se il nome non è valido per un ELEMENT
-- Modify date: 2019-01-22 Refactoring cambio schema
-- Modify date: 2020-04-22 Aggiunti attributi IdEsternoVecchio, IdEsternoNuovo letto da riferimenti (ultimo)
-- Modify date: 2020-05-18 ETTORE: Non restituisco gli attributi persistenti del referto (iniziano con $@)
-- Modify date: 2020-11-17 SANDRO: Aggiunto campo Firmato
-- Modify date: 2020-12-29 SANDRO:  Rinomino '$@NumeroVersione' traslando il nome -> 'Dwh_NumeroVersione'
--									Rinomino '$@Sole-IdDocumento' traslando il nome -> 'Dwh_Sole-IdDocumento'
--									Diversamente dal DWH OUT non uso Dwh@ ma Dwh_
--
-- ATTENZIONE:	Al connettore SOLE attributi con @ non è corretto inviarli
--				Il connettore SOLE BIZTALK trasforma per questione storiche tutti gli attributi in ELEMENTI
--				di un suo NODO usando il Nome dell'attributo.
--
-- Description:	Ritorna il REFERTO XML formato SOLE
--				Copiata da [dbo].[GetRefertoXmlForSole]
--				Ritorna anche il nodo Ricovero (se nosologico trovato)
-- =============================================
CREATE FUNCTION [sole].[OttieneRefertoXml]
(
 @Id uniqueidentifier
)  
RETURNS XML AS  
BEGIN 
/*
 Ritorna un segmento XML di tutto il referto, prestazioni e allegato complesi
	namespace = nessuno

TODO: tutte le query non usano DataPartizione
*/
DECLARE @XmlReferto xml

	IF NOT @ID IS NULL
	BEGIN
		--
		-- Prestazioni
		--
		DECLARE @XmlPrestazioni xml
		SET @XmlPrestazioni = (
			SELECT Prestazione.Id, Prestazione.IdEsterno,
				Prestazione.DataInserimento, Prestazione.DataModifica,
				--Prestazione.DataErogazione, --NEL flusso CDA non è valorizzato
				COALESCE(Prestazione.DataErogazione, (SELECT DataReferto FROM store.RefertiBase WHERE Id=@ID)) AS DataErogazione,
				
				Prestazione.PrestazioneCodice, Prestazione.PrestazioneDescrizione, 
				Prestazione.SezioneCodice, Prestazione.SezioneDescrizione,
				
				Prestazione.GravitaCodice, Prestazione.GravitaDescrizione,
				
				CONVERT(VARCHAR(16), dbo.GetPrestazioniAttributoDecimal( Prestazione.Id, Prestazione.DataPartizione, 'Quantita')) as Quantita,

				Prestazione.Risultato, Prestazione.ValoriRiferimento,
				Prestazione.SezionePosizione, Prestazione.PrestazionePosizione,
				Prestazione.Commenti,

				CONVERT(XML ,( 
						SELECT [sole].[NomeAttributoCodifica](Attributo.Nome) Nome
							-- Per un errore su SOLE formatto il campo Quantità
							, CASE WHEN Attributo.Nome = 'Quantita' THEN dbo.GetPrestazioniAttributoDecimal(
																			 Prestazione.Id, Prestazione.DataPartizione
																			 , Attributo.Nome)
								ELSE Attributo.Valore END AS Valore
						
						FROM store.PrestazioniAttributi AS Attributo
						WHERE Attributo.IdPrestazioniBase = Prestazione.Id
							AND Attributo.DataPartizione = Prestazione.DataPartizione
						ORDER BY Attributo.Nome
						FOR XML AUTO
						)) AS Attributi

			FROM store.Prestazioni AS Prestazione
			WHERE Prestazione.IdRefertiBase = @ID
			ORDER BY  Prestazione.IdEsterno
			FOR XML AUTO, ELEMENTS
				)
		--
		-- Allegati
		--
		DECLARE @XmlAllegati xml
		SET @XmlAllegati = (
			SELECT Allegato.ID, Allegato.IdEsterno,
					Allegato.DataInserimento, Allegato.DataModifica,
					Allegato.DataFile, Allegato.MimeType, Allegato.MimeData,
					NULLIF(Allegato.NomeFile, 'NomeFile') AS NomeFile,
					Allegato.Descrizione, Allegato.Posizione,
					Allegato.StatoCodice, Allegato.StatoDescrizione,
					
					CONVERT(XML, (
						SELECT [sole].[NomeAttributoCodifica](Attributo.Nome) Nome
								, Attributo.Valore
						FROM store.AllegatiAttributi AS Attributo
						WHERE Attributo.IdAllegatiBase = Allegato.Id
							AND Attributo.DataPartizione = Allegato.DataPartizione

						ORDER BY  Attributo.Nome
						FOR XML AUTO
						)) AS Attributi

			FROM store.Allegati AS Allegato
			WHERE Allegato.IdRefertiBase = @ID
				AND Allegato.MimeType IN ('application/pdf', 'text/xml') -- 15-01-2013 Sandro, per escludere i P7M
																		 -- 13-01-2014 Sandro, solo PDF e XML
			ORDER BY  Allegato.IdEsterno
			FOR XML AUTO, ELEMENTS, BINARY BASE64
				)
		--
		-- Dati dale referto (2015-08-19)
		--
		DECLARE @DataModificaEsterno AS DATETIME
		DECLARE @StatoRichiestaCodice AS TINYINT
		DECLARE @AziendaErogante AS VARCHAR(16)
		DECLARE @NumeroNosologico AS VARCHAR(64)

		SELECT @StatoRichiestaCodice = StatoRichiestaCodice
				,@DataModificaEsterno = DataModificaEsterno
				,@AziendaErogante = AziendaErogante
				,@NumeroNosologico = NumeroNosologico
			FROM store.RefertiBase AS Referto	WHERE Referto.Id = @ID
		--
		-- Ricovero del referto
		--
		DECLARE @XmlRicovero AS XML = [sole].[OttieneRicoveroXml]( @AziendaErogante, @NumeroNosologico)
		--
		-- Aggiungo attributi referto (2012-06-08)
		--
		DECLARE @TableAttibutiReferto AS TABLE (Nome VARCHAR(64), Valore SQL_VARIANT )
		INSERT INTO @TableAttibutiReferto (Nome, Valore) VALUES ('StatoRichiestaCodice', @StatoRichiestaCodice)

		--
		-- Aggiungo attributi referto catena sostituzioni (2020-04-24)
		--
		DECLARE @IdEsternoVecchio VARCHAR(64)
		DECLARE @IdEsternoNuovo VARCHAR(64)
		SELECT TOP 1 @IdEsternoVecchio = IdEsternoVecchio
					,@IdEsternoNuovo = IdEsternoNuovo
			FROM [dbo].[OttieniRefertoRiferimenti]( @Id, NULL)
			ORDER BY DataModificaEsterno DESC
		
		INSERT INTO @TableAttibutiReferto (Nome, Valore) VALUES ('IdEsternoVecchio', @IdEsternoVecchio)
		INSERT INTO @TableAttibutiReferto (Nome, Valore) VALUES ('IdEsternoNuovo', @IdEsternoNuovo)
		--		
		--
		-- Attributi
		--	Per EIM rinomine REFERTO in Referto		
		DECLARE @XmlAttributi xml
		SET @XmlAttributi = (
				SELECT Nome, Valore FROM 
					(SELECT Nome, Valore
					FROM @TableAttibutiReferto
					
					UNION
			
					SELECT CASE Attributo.Nome WHEN 'REFERTO' THEN 'Referto'
											   WHEN '$@NumeroVersione' THEN 'Dwh_NumeroVersione'
											   WHEN '$@Sole-IdDocumento' THEN 'Dwh_Sole-IdDocumento'
							ELSE [sole].[NomeAttributoCodifica](Attributo.Nome) END AS Nome
						, Attributo.Valore
					FROM store.RefertiAttributi AS Attributo
					WHERE Attributo.IdRefertiBase = @ID
						--- 2012-03-16 Elimina attributo errato
						AND NOT CONVERT(VARCHAR(64), Attributo.Valore) LIKE Attributo.Nome + '%'

						--- 2017-02-16: Rimuove l'attributo CONFIDENZIALE = NO
						AND NOT (Attributo.Nome = 'Confidenziale' AND Attributo.Valore = 'NO')

						-- NOTA da verificare
						-- 2019-03-04: Negli eventi questi vengono rimossi. Nei referti?
						--AND NOT Attributo.Nome IN ('CodiceAnagraficaCentrale','NomeAnagraficaCentrale'
						--							, 'IdEsternoPaziente', 'CodiceSanitario', 'Sesso'
						--							, 'Cognome','Nome','DataNascita','CodiceFiscale')

						--- 2017-10-25: Rimuove gli attributi aggiunti da SOLE
						AND NOT Attributo.Nome LIKE 'Sole-%'
						--
						-- Non vengono restituiti gli attributi persistenti del referto
						-- Restituisco '$@NumeroVersione' '$@Sole-IdDocumento' traslando il nome
						AND ( 
								(NOT Attributo.Nome LIKE '$@%')
								OR 
								Attributo.Nome IN ('$@NumeroVersione', '$@Sole-IdDocumento')
							)

					) Attributo
				WHERE NOT Attributo.Valore IS NULL
				ORDER BY  Attributo.Nome
				FOR XML AUTO
						)
		--
		-- Referto
		--	
		SET @XmlReferto = (
			SELECT Referto.Id, Referto.IdEsterno,
				@DataModificaEsterno AS DataModificaEsterno,
				[dbo].[GetPazienteAttivoByIdSac](Referto.IdPaziente) AS IdPaziente, 
				[sole].[OttieneSacPazienteXml](Referto.IdPaziente) AS Paziente,
				Referto.DataInserimento, Referto.DataModifica,
				Referto.AziendaErogante, Referto.SistemaErogante, Referto.RepartoErogante, 
				Referto.DataReferto, Referto.NumeroReferto, 
				Referto.NumeroPrenotazione, Referto.NumeroNosologico,
				Referto.IdOrderEntry AS IdRichiestaOE,
				
				Referto.StatoRichiestaCodice,
				[dbo].[GetRefertoStatoDesc](NULL, CONVERT(VARCHAR(16), Referto.StatoRichiestaCodice), NULL
						) AS StatoRichiestaDescrizione,

				Referto.RepartoRichiedenteCodice,
				Referto.RepartoRichiedenteDescr AS RepartoRichiedenteDescrizione,
				
				Referto.PrioritaCodice AS PrioritaCodice,
				Referto.PrioritaDescr AS PrioritaDescrizione,

				Referto.TipoRichiestaCodice AS TipoRichiestaCodice,
				Referto.TipoRichiestaDescr AS TipoRichiestaDescrizione,

				dbo.GetRefertoTesto( Referto.Id, Referto.DataPartizione) AS TestoReferto,

				Referto.MedicoRefertanteCodice AS MedicoRefertanteCodice,
				Referto.MedicoRefertanteDescr AS MedicoRefertanteDescrizione,
				
				Referto.Cognome AS PazienteCognome,
				Referto.Nome AS PazienteNome,
				Referto.Sesso AS PazienteSesso,
				Referto.CodiceFiscale AS PazienteCodiceFiscale,
				Referto.DataNascita AS PazienteDataNascita,
				Referto.ComuneNascita AS PazienteComuneNascita,
				
				CONVERT(VARCHAR(64), [dbo].[GetRefertiAttributo]( Referto.Id, 'ComuneResidenza')) AS PazienteComuneResidenza,
				Referto.CodiceSanitario AS PazienteCodiceSanitario,

				Referto.Firmato AS Firmato,
				
				@XmlPrestazioni AS Prestazioni,
				@XmlAllegati AS Allegati,
				@XmlAttributi AS Attributi,
				@XmlRicovero AS Ricovero

			FROM store.Referti AS Referto
			WHERE Referto.Id = @ID
			FOR XML AUTO, ELEMENTS
				)
	END

	RETURN @XmlReferto
END