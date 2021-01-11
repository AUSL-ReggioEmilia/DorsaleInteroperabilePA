

CREATE FUNCTION [dbo].[GetRefertoXml2]
(
@Id UNIQUEIDENTIFIER
)
RETURNS XML
AS 
BEGIN 
/*
 Ritorna un segmento XML di tutto il referto, prestazioni e allegato complesi
	namespace = http://schemas.progel.it/SQL/Dwh/QueueRefertoOutput/1.0
	
	Creata il: 2012-02-15
	Modificata il: 2012-03-15
	Modificata il: 2012-09-17: ETTORE - traslazione dell'IdPaziente nell'Id del paziente attivo
	Modificata il: 2014-05-30: SANDRO - restituzione negli attributi dei dati di testata DataEvento, Firmato
	Modificata il: 2015-08-19: SANDRO - Usa le VIEW store. Invece di AllegatiBase usa Allegati che gestisce MineDataCompresso
													Prestazioni e Referti usate per ottimizare accesso agli attributi
	Modificata il: 2017-09-05: SANDRO - Nuovi attributi di OSCURAMENTO
	Modificata il: 2020-05-18: ETTORE -Non vengono restituiti gli attributi persistenti del referto
											Restituisco '$@NumeroVersione' traslando il nome -> 'Dwh@NumeroVersione'
	Modificata il: 2020-12-29: SANDRO -Restituisco '$@Sole-IdDocumento' traslando il nome -> 'Dwh@Sole-IdDocumento'

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
				Prestazione.DataErogazione,
				Prestazione.PrestazioneCodice, Prestazione.PrestazioneDescrizione, 
				Prestazione.SezioneCodice, Prestazione.SezioneDescrizione,
				
				Prestazione.GravitaCodice, Prestazione.GravitaDescrizione,
				CONVERT(VARCHAR(16), dbo.GetPrestazioniAttributo( Prestazione.Id, Prestazione.DataPartizione, 'Quantita')) as Quantita,

				Prestazione.Risultato, Prestazione.ValoriRiferimento,
				Prestazione.SezionePosizione, Prestazione.PrestazionePosizione,
				Prestazione.Commenti,

				CONVERT(XML ,( 
						SELECT Attributo.Nome, Attributo.Valore
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
						SELECT Attributo.Nome, Attributo.Valore
						FROM store.AllegatiAttributi AS Attributo
						WHERE Attributo.IdAllegatiBase = Allegato.Id
							AND Attributo.DataPartizione = Allegato.DataPartizione
						ORDER BY  Attributo.Nome
						FOR XML AUTO
						)) AS Attributi
			FROM store.Allegati AS Allegato
			WHERE Allegato.IdRefertiBase = @ID
			ORDER BY  Allegato.IdEsterno
			FOR XML AUTO, ELEMENTS, BINARY BASE64
				)
		--
		-- Attributi Referto
		--
		-- Leggo dalla tabella RefertiBase i campi "DataEvento", "Firmato" da restituire negli attributi
		DECLARE @AttributoDataEvento VARCHAR(30)
		DECLARE @AttributoFirmato VARCHAR(1)
		DECLARE @DataModificaEsterno DATETIME	--Serve nel nodo Referto

		DECLARE @OscuramentoMassivo VARCHAR(8000) = NULL
		DECLARE @OscuramentoPuntuale BIT = 0
		DECLARE @OscuramentoPaziente BIT = 0
		DECLARE @Oscurato BIT = 0
		DECLARE @Confidenziale BIT = 0
		--
		-- Altri 
		--- Per la data il formato giusto sarebbe il 126 con il T
		--
		SELECT @AttributoDataEvento = CONVERT(VARCHAR(30), DataEvento, 121)
			 , @AttributoFirmato = CAST(Firmato AS VARCHAR(1))
			 , @DataModificaEsterno = DataModificaEsterno
		FROM store.RefertiBase where Id = @Id
		--
		-- Calcolo oscuramenti
		--
		SELECT @OscuramentoMassivo = dbo.GetRefertoOscuramentiString(Id, DataPartizione, AziendaErogante
																, SistemaErogante, StrutturaEroganteCodice
																, NumeroNosologico, RepartoRichiedenteCodice
																, RepartoErogante, Confidenziale)

			, @OscuramentoPuntuale = dbo.GetRefertoOscuramentiPuntuali(IdEsterno, AziendaErogante, SistemaErogante
																		, NumeroNosologico, NumeroPrenotazione
																		, NumeroReferto, IdOrderEntry)

			, @OscuramentoPaziente = CASE WHEN EXISTS (SELECT * FROM PazientiCancellati  
														WHERE PazientiCancellati.IdPazientiBase = IdPaziente
														AND PazientiCancellati.IdRepartiEroganti IS NULL)
										THEN 1 ELSE 0 END
			, @Confidenziale = Confidenziale

		FROM store.Referti where Id = @Id

		IF NOT @OscuramentoMassivo IS NULL OR @OscuramentoPuntuale = 1 OR @OscuramentoPaziente = 1
			SET @Oscurato = 1
		--
		-- Aggiungo a tabella temporanea
		--
		DECLARE @TableAttibutiReferti AS TABLE (Nome VARCHAR(64), Valore SQL_VARIANT)
		INSERT INTO @TableAttibutiReferti (Nome, Valore) VALUES ('DataEvento', @AttributoDataEvento)
		INSERT INTO @TableAttibutiReferti (Nome, Valore) VALUES ('Firmato', @AttributoFirmato)
		
		IF @Confidenziale = 1
		BEGIN
			INSERT INTO @TableAttibutiReferti (Nome, Valore) VALUES ('Confidenziale', CASE WHEN @Confidenziale = 1 THEN 'SI' ELSE 'NO' END)
		END

		IF @Oscurato = 1
		BEGIN
			INSERT INTO @TableAttibutiReferti (Nome, Valore) VALUES ('Oscurato', CASE WHEN @Oscurato = 1 THEN 'SI' ELSE 'NO' END)
			INSERT INTO @TableAttibutiReferti (Nome, Valore) VALUES ('OscuratoCodici', @OscuramentoMassivo)
			INSERT INTO @TableAttibutiReferti (Nome, Valore) VALUES ('OscuratoMassivo', CASE WHEN NOT @OscuramentoMassivo IS NULL THEN 'SI' ELSE 'NO' END)
			INSERT INTO @TableAttibutiReferti (Nome, Valore) VALUES ('OscuratoPuntuale',  CASE WHEN @OscuramentoPuntuale = 1 THEN 'SI' ELSE 'NO' END)
			INSERT INTO @TableAttibutiReferti (Nome, Valore) VALUES ('OscuratoPaziente', CASE WHEN @OscuramentoPaziente = 1 THEN 'SI' ELSE 'NO' END)
		END

		-- Determino tutti gli attributi
		DECLARE @XmlAttributiReferto xml
		SET @XmlAttributiReferto = (			
				CONVERT(XML, (SELECT Nome , Valore FROM (
								
								--Includo gli attributi aggiunti
								SELECT Nome, Valore	FROM @TableAttibutiReferti
								UNION ALL

								SELECT 
									CASE Attributo.Nome WHEN '$@NumeroVersione' THEN 'Dwh@NumeroVersione'
														WHEN '$@Sole-IdDocumento' THEN 'Dwh@Sole-IdDocumento'
										ELSE Attributo.Nome  END AS Nome
									, Attributo.Valore
								FROM store.RefertiAttributi AS Attributo INNER JOIN store.RefertiBase AS Referto
										ON Attributo.IdRefertiBase = Referto.Id
										AND (Attributo.DataPartizione = Referto.DataPartizione)
								WHERE Referto.ID = @Id
									--escludo gli attributi aggiunti
									AND NOT EXISTS (SELECT * FROM @TableAttibutiReferti ta WHERE ta.Nome = Attributo.Nome)
									--
									-- Non vengono restituiti gli attributi persistenti del referto
									-- Restituisco '$@NumeroVersione' traslando il nome -> 'Dwh@NumeroVersione' 
									--			   '$@Sole-IdDocumento' traslando il nome -> 'Dwh@Sole-IdDocumento' 
									AND ( 
											(NOT Attributo.Nome LIKE '$@%')
											OR 
											Attributo.Nome IN ('$@NumeroVersione', '$@Sole-IdDocumento')
										)
								) AS Attributo
							ORDER BY Nome
							FOR XML AUTO
				)) 
		)
		--
		-- Referto
		--	
		;WITH XMLNAMESPACES ( 'http://schemas.progel.it/SQL/Dwh/QueueRefertoOutput/1.0' as ns0 ) 
		SELECT @XmlReferto = (
			SELECT "ns0:Referto".Id, "ns0:Referto".IdEsterno,
				@DataModificaEsterno AS DataModificaEsterno,
				dbo.GetPazienteAttivoByIdSac("ns0:Referto".IdPaziente) AS IdPaziente, 
				--
				-- CodiceAnagraficaCentrale
				--
				CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( "ns0:Referto".Id, 'CodiceAnagraficaCentrale')) AS CodiceAnagraficaCentrale,
				--
				-- NomeAnagraficaCentrale
				--
				CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( "ns0:Referto".Id, 'NomeAnagraficaCentrale')) AS NomeAnagraficaCentrale,
				dbo.GetSacPazienteXmlById(dbo.GetPazienteAttivoByIdSac("ns0:Referto".IdPaziente)) AS Paziente,
				
				"ns0:Referto".DataInserimento, "ns0:Referto".DataModifica,
				"ns0:Referto".AziendaErogante, "ns0:Referto".SistemaErogante,
				"ns0:Referto".RepartoErogante AS RepartoEroganteDescrizione, 
				
				"ns0:Referto".DataReferto, "ns0:Referto".NumeroReferto, 
				"ns0:Referto".NumeroPrenotazione, "ns0:Referto".NumeroNosologico,
				"ns0:Referto".IdOrderEntry AS IdRichiestaOE,
				"ns0:Referto".StatoRichiestaCodice,
				dbo.GetRefertoStatoDesc(NULL, CONVERT(VARCHAR(16), "ns0:Referto".StatoRichiestaCodice), NULL
						) AS StatoRichiestaDescrizione,
				
				"ns0:Referto".RepartoRichiedenteCodice AS RepartoRichiedenteCodice,
				"ns0:Referto".RepartoRichiedenteDescr AS RepartoRichiedenteDescrizione,
				
				"ns0:Referto".PrioritaCodice AS PrioritaCodice,
				"ns0:Referto".PrioritaDescr AS PrioritaDescrizione,

				"ns0:Referto".TipoRichiestaCodice AS TipoRichiestaCodice,
				"ns0:Referto".TipoRichiestaDescr AS TipoRichiestaDescrizione,

				dbo.GetRefertoTesto( "ns0:Referto".Id, "ns0:Referto".DataPartizione) AS TestoReferto,

				"ns0:Referto".MedicoRefertanteCodice AS MedicoRefertanteCodice,
				"ns0:Referto".MedicoRefertanteDescr AS MedicoRefertanteDescrizione,
				
				"ns0:Referto".Cognome AS PazienteCognome,
				"ns0:Referto".Nome AS PazienteNome,
				"ns0:Referto".Sesso AS PazienteSesso,
				"ns0:Referto".CodiceFiscale AS PazienteCodiceFiscale,
				"ns0:Referto".DataNascita AS PazienteDataNascita,
				"ns0:Referto".ComuneNascita AS PazienteComuneNascita,
				CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( "ns0:Referto".Id, 'ComuneResidenza')) AS PazienteComuneResidenza,
				"ns0:Referto".CodiceSanitario AS PazienteCodiceSanitario,

				
				@XmlPrestazioni AS Prestazioni,
				@XmlAllegati AS Allegati,
				@XmlAttributiReferto as Attributi

			FROM store.Referti AS "ns0:Referto"
			WHERE "ns0:Referto".Id = @ID
			FOR XML AUTO, ELEMENTS
				)
	END

	RETURN @XmlReferto
END
