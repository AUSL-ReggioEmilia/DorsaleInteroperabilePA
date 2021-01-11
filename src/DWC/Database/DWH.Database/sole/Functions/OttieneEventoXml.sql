

-- =============================================
-- Author:		Alessandro Nostini

-- Create date: 2012-07-11: Aggiunto noto Ricovero
-- Modify date: 2012-09-17: traslazione dell'IdPaziente nell'IdPaziente attivo
-- Modify date: 2014-03-14 Se E converto in X 						
-- Modify date: 2015-09-24: Usa le VIEW store
--							Prestazioni e Referti usate per ottimizare accesso agli attributi
-- Modify date: 2016-10-02: Rimuove gli attributi con NOME con caratteri parentesi
-- Modify date: 2018-09-14: Usa [dbo].[SoleOttieneSacPazienteXml]() stessa function dei Referti
-------------------------------------------------------------
-- Create date: 2017-10-24: Rinominata
-- Modify date: 2018-02-14: Codifico il nome attributo con [dbo].[SoleNomeAttributoCodifica]()
--								Previene un problema di mappa se il nome non è valido per un ELEMENT
--
-- Modify date: 2018-09-14: Sandro:  Ho notato che non usa la stessa function dei Referti
--									Ora userà [dbo].[SoleOttieneSacPazienteXml]()
--											che è stata allineata a livello di Element 
-- Modify date: 2019-01-22 Refactoring cambio schema
-- Modify date: 2020-12-29 Non restituisco gli attributi persistenti (iniziano con $@)
--
-- Description:	Ritorna l'EVENTO XML formato SOLE
--				namespace = http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0
--				Copiata da [dbo].[GetEventoXmlForSole]
-- =============================================
CREATE FUNCTION [sole].[OttieneEventoXml]
(@Id UNIQUEIDENTIFIER)
RETURNS XML
AS
BEGIN 
/*
 Copiata da [dbo].[GetEventoXmlForSole]
*/
DECLARE @XmlAnagrafica xml
DECLARE @XmlEvento xml
		
	IF NOT @ID IS NULL
	BEGIN
		--
		-- Ricavo l'Id dell'evento di accettazione
		--
		DECLARE @AziendaErogante as VARCHAR(16)
		DECLARE @NumeroNosologico as VARCHAR(64)
		DECLARE @IdEventoAccettazione as uniqueidentifier
		DECLARE @TipoEventoCodice as VARCHAR(16)
		
		SELECT @AziendaErogante=AziendaErogante
				, @NumeroNosologico=NumeroNosologico
				, @TipoEventoCodice = TipoEventoCodice
		FROM store.EventiBase WHERE Id = @Id
		--
		-- Inizializzo e ricavo l'Id dell'evento di accettazione 
		--
		SET @IdEventoAccettazione = @Id
		IF @TipoEventoCodice <> 'A'
		BEGIN
			SELECT TOP 1
				@IdEventoAccettazione = Id
			FROM store.EventiBase WHERE AziendaErogante=@AziendaErogante 
									AND NumeroNosologico = @NumeroNosologico
										AND StatoCodice=0 AND TipoEventoCodice = 'A'
		END	
		--
		-- Creo attributi Evento
		--
		DECLARE @TableAttibutiEventi AS TABLE (Nome VARCHAR(64), Valore SQL_VARIANT )

		INSERT INTO @TableAttibutiEventi (Nome, Valore) SELECT 'TipoEpisodioCodice', TipoEpisodio
														FROM store.EventiBase WHERE Id = @ID

		INSERT INTO @TableAttibutiEventi (Nome, Valore) SELECT 'TipoEpisodioDescrizione'
																, NULLIF(dbo.GetEventiTipoEpisodioDesc(NULL
																, CONVERT(VARCHAR(16), TipoEpisodio), NULL), '')
														FROM store.EventiBase WHERE Id = @ID
														
		INSERT INTO @TableAttibutiEventi (Nome, Valore) SELECT 'RepartoCodice', RepartoCodice
														FROM store.EventiBase WHERE Id = @ID
		INSERT INTO @TableAttibutiEventi (Nome, Valore) SELECT 'RepartoDescrizione', RepartoDescr
														FROM store.EventiBase WHERE Id = @ID
														
		INSERT INTO @TableAttibutiEventi (Nome, Valore) SELECT 'Diagnosi', Diagnosi
														FROM store.EventiBase WHERE Id = @ID
		--
		-- Attributi Evento
		--
		DECLARE @XmlAttributiEvento AS XML
		SET @XmlAttributiEvento = (
				CONVERT(XML, ( SELECT Nome, Valore FROM 
									(SELECT Nome, Valore
									FROM @TableAttibutiEventi
									
									UNION
									
									SELECT [sole].[NomeAttributoCodifica](Attributo.Nome) Nome
											, Attributo.Valore
									FROM store.EventiAttributi AS Attributo
										INNER JOIN store.EventiBase AS Evento
									ON Attributo.IdEventiBase = Evento.Id
										AND Attributo.DataPartizione = Evento.DataPartizione
									WHERE Evento.Id = @ID
										AND NOT Attributo.[Nome] IN ('CodiceAnagraficaCentrale','NomeAnagraficaCentrale'
													, 'IdEsternoPaziente', 'CodiceSanitario', 'Sesso'
													, 'Cognome','Nome','DataNascita','CodiceFiscale')

										--- 2017-10-25: Rimuove gli attributi aggiunti da SOLE
										AND NOT Attributo.Nome LIKE 'Sole-%'

										-- 2020-12-29 Non restituisco gli attributi persistenti
										AND NOT Attributo.Nome LIKE '$@%'
									) Attributo
							WHERE NOT Attributo.Valore IS NULL
							ORDER BY  Attributo.Nome
							FOR XML AUTO
							)) 
						)
		--
		-- Ricovero dell'Evento
		--
		DECLARE @XmlRicovero AS XML = [sole].[OttieneRicoveroXml]( @AziendaErogante, @NumeroNosologico)
		--
		-- Evento
		--	
		;WITH XMLNAMESPACES ('http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0' as ns0)
		SELECT @XmlEvento = (
			SELECT "ns0:Evento".Id, "ns0:Evento".IdEsterno
				,[dbo].[GetPazienteAttivoByIdSac]("ns0:Evento".IdPaziente) AS IdPaziente
				-- Ricavo CodiceAnagraficaCentrale e NomeAnagraficaCentrale
				,CAST(dbo.GetEventiAttributo(@IdEventoAccettazione, 'CodiceAnagraficaCentrale') AS VARCHAR(64)) AS CodiceAnagraficaCentrale
				,CAST(dbo.GetEventiAttributo(@IdEventoAccettazione, 'NomeAnagraficaCentrale') AS VARCHAR(64)) AS NomeAnagraficaCentrale
				
				-- Ricavo paziente da SAC
				,[sole].[OttieneSacPazienteXml]("ns0:Evento".IdPaziente) AS Paziente
				--2018-09-14 Ho notato che non usa la stessa function dei Referti
				-- Allineate le due function a livello di Element

				,"ns0:Evento".DataInserimento, "ns0:Evento".DataModifica
				,"ns0:Evento".AziendaErogante, "ns0:Evento".SistemaErogante
				
				,"ns0:Evento".DataEvento
					
				--Sandro 2014-03-14 Se E converto in X 						
				,CASE "ns0:Evento".TipoEventoCodice WHEN 'E' THEN 'X'
											ELSE "ns0:Evento".TipoEventoCodice END TipoEventoCodice
				,"ns0:Evento".TipoEventoDescr AS TipoEventoDescrizione
				
				,"ns0:Evento".NumeroNosologico
			
				,@XmlAttributiEvento AS Attributi
				,@XmlRicovero AS Ricovero
			FROM store.EventiBase AS "ns0:Evento"
			WHERE "ns0:Evento".Id = @ID
			FOR XML AUTO, ELEMENTS
				)
	END

	RETURN @XmlEvento
END