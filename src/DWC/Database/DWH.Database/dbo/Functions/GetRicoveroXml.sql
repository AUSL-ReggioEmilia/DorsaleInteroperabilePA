

-- =============================================
-- Author:		ETTORE
-- Create date: 2013-02-22: Non ancora usata è una preview e serve per debug
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2019-04-05 Aggiunta filtro Evento.StatoCodice = 0 a lista degli eventi
-- Modify date: 2020-12-29  SANDRO - Non restituisco gli attributi persistenti
--
-- Description:	sandro ?? non sembra usata??
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveroXml]
(
 @AziendaErogante as VARCHAR(16)
,@NumeroNosologico as VARCHAR(64)
)
RETURNS XML
AS
BEGIN 
/*
 Ritorna un segmento XML di tutto l'Evento
	namespace = http://schemas.progel.it/SQL/Dwh/QueueRicoveroOutput/1.0
*/
DECLARE @XmlRicovero AS XML
		
	IF NOT @AziendaErogante IS NULL AND NOT @NumeroNosologico IS NULL
	BEGIN
	
		DECLARE @IdEventoAccettazione AS UNIQUEIDENTIFIER
		SELECT TOP 1 @IdEventoAccettazione = Id
			FROM store.EventiBase
			WHERE AziendaErogante=@AziendaErogante 
					AND NumeroNosologico = @NumeroNosologico
					AND StatoCodice=0 AND TipoEventoCodice = 'A'
		--
		-- Eventi
		--
		DECLARE @XmlEventi AS XML
		SET @XmlEventi = (
				CONVERT(XML, ( SELECT Id, IdEsterno
									, DataInserimento, DataModifica
									, AziendaErogante, SistemaErogante
									, DataEvento, StatoCodice
									, TipoEventoCodice, TipoEventoDescr
									, NumeroNosologico, TipoEpisodio
									, RepartoCodice, RepartoDescr
									, Diagnosi
									
									,CONVERT(XML, (
											SELECT Attributo.Nome, Attributo.Valore
											FROM store.EventiAttributi AS Attributo
											WHERE Attributo.IdEventiBase = Evento.Id
												AND Attributo.DataPartizione = Evento.DataPartizione
												AND NOT Attributo.[Nome] IN ('CodiceAnagraficaCentrale','NomeAnagraficaCentrale'
																	, 'IdEsternoPaziente', 'CodiceSanitario'
																	, 'Cognome','Nome','DataNascita','CodiceFiscale')
												AND NOT Attributo.Valore IS NULL

												-- 2020-12-29 Non restituisco gli attributi persistenti
												AND (NOT Attributo.Nome LIKE '$@%')

											ORDER BY  Attributo.Nome
											FOR XML AUTO
											)) AS Attributi
									
								FROM store.EventiBase AS Evento
								WHERE Evento.AziendaErogante = @AziendaErogante
										AND Evento.NumeroNosologico = @NumeroNosologico
										AND Evento.StatoCodice = 0
							ORDER BY  Evento.DataEvento
							FOR XML AUTO, ELEMENTS
							)) 
						)						
		
		-- Attributi Ricovero
		
		DECLARE @XmlAttributiRicovero AS XML
		SET @XmlAttributiRicovero = (
				CONVERT(XML, (
							SELECT Attributo.Nome, Attributo.Valore
							FROM store.RicoveriAttributi AS Attributo
								INNER JOIN store.RicoveriBase AS Ricovero
							ON Attributo.IdRicoveriBase = Ricovero.Id
								AND Attributo.DataPartizione = Ricovero.DataPartizione
							WHERE Ricovero.[NumeroNosologico] = @NumeroNosologico
								AND Ricovero.[AziendaErogante] = @AziendaErogante
								AND NOT [Nome] IN ('CodiceAnagraficaCentrale','NomeAnagraficaCentrale'
													, 'IdEsternoPaziente')
							ORDER BY  Attributo.Nome
							FOR XML AUTO
							)) 
						)				
		--
		-- Ricovero
		--	
		;WITH XMLNAMESPACES ('http://schemas.progel.it/SQL/Dwh/QueueRicoveroOutput/1.0' as ns0)
		SELECT @XmlRicovero = (
			
				SELECT "ns0:Ricovero".[Id], "ns0:Ricovero".[IdEsterno]
					,"ns0:Ricovero".[DataInserimento], "ns0:Ricovero".[DataModifica]
					,"ns0:Ricovero".[AziendaErogante], "ns0:Ricovero".[SistemaErogante]

					,dbo.GetPazienteAttivoByIdSac("ns0:Ricovero".IdPaziente) AS IdPaziente
					-- Ricavo CodiceAnagraficaCentrale e NomeAnagraficaCentrale
					,CAST(dbo.GetEventiAttributo(@IdEventoAccettazione, 'CodiceAnagraficaCentrale') AS VARCHAR(64)) AS CodiceAnagraficaCentrale
					,CAST(dbo.GetEventiAttributo(@IdEventoAccettazione, 'NomeAnagraficaCentrale') AS VARCHAR(64)) AS NomeAnagraficaCentrale
				
					,CAST(NULL AS VARCHAR(64)) AS CodiceAnagraficaCentrale
					,CAST(NULL AS VARCHAR(64)) AS NomeAnagraficaCentrale
		
					-- Ricavo paziente da SAC
					,dbo.GetSacPazienteXmlById(dbo.GetPazienteAttivoByIdSac("ns0:Ricovero".IdPaziente)) AS Paziente		

					,"ns0:Ricovero".[StatoCodice]
					,CASE "ns0:Ricovero".[StatoCodice]
							WHEN 0 THEN 'Prenotazione'
							WHEN 1 THEN 'Accettazione'
							WHEN 2 THEN 'In reparto'
							WHEN 3 THEN 'Dimissione'
							WHEN 4 THEN 'Riapertura'
							WHEN 5 THEN 'Cancellazione'
							WHEN 255 THEN 'Incompleto'
							ELSE 'Stato sconosciuto'
						END AS StatoDescrizione
						
					,"ns0:Ricovero".[TipoRicoveroCodice], NULLIF("ns0:Ricovero".[TipoRicoveroDescr], '') AS [TipoRicoveroDescrizione]

					-- Al momento non ho i codici diagnosi
					,CONVERT(VARCHAR(64), NULL) AS DiagnosiCodice
					,"ns0:Ricovero".[Diagnosi] AS DiagnosiDescrizione
					,CONVERT(VARCHAR(1024), NULL) AS DiagnosiDescrizioneLibera

					,"ns0:Ricovero".[DataAccettazione], "ns0:Ricovero".[DataDimissione]
					,"ns0:Ricovero".[RepartoAccettazioneCodice], "ns0:Ricovero".[RepartoAccettazioneDescr] AS [RepartoAccettazioneDescrizione]
					,CASE WHEN NOT "ns0:Ricovero".[DataDimissione] IS NULL THEN "ns0:Ricovero".[RepartoCodice] ELSE NULL END AS [RepartoDimissioneCodice]
					,CASE WHEN NOT "ns0:Ricovero".[DataDimissione] IS NULL THEN "ns0:Ricovero".[RepartoDescr] ELSE NULL END AS [RepartoDimissioneDescrizione]
					
					,"ns0:Ricovero".[DataTrasferimento]
					,"ns0:Ricovero".[OspedaleCodice], "ns0:Ricovero".[OspedaleDescr] AS [OspedaleDescrizione]
					,"ns0:Ricovero".[RepartoCodice], "ns0:Ricovero".[RepartoDescr] AS [RepartoDescrizione]
					,"ns0:Ricovero".[SettoreCodice], "ns0:Ricovero".[SettoreDescr] AS [SettoreDescrizione]
					,"ns0:Ricovero".[LettoCodice], CONVERT(VARCHAR(64), NULL) AS [LettoDescrizione]
					
					,@XmlAttributiRicovero AS Attributi
					
					,@XmlEventi AS Eventi
				
				FROM store.RicoveriBase AS "ns0:Ricovero"
				WHERE "ns0:Ricovero".[NumeroNosologico] = @NumeroNosologico
					AND "ns0:Ricovero".[AziendaErogante] = @AziendaErogante
				FOR XML AUTO, ELEMENTS
				)
	END

	RETURN @XmlRicovero
END
