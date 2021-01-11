
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2017-10-24
-- Create date: 2018-02-14: Codifico il nome attributo con [dbo].[SoleNomeAttributoCodifica]()
--								Previene un problema di mappa se il nome non è valido per un ELEMENT
-- Modify date: 2019-01-22 Refactoring cambio schema
-- Modify date: 2019-02-19 Aggiunta la lista degli eventi
-- Modify date: 2019-04-05 Aggiunta filtro Evento.StatoCodice = 0 a lista degli eventi
-- Modify date: 2020-12-29 Non restituisco gli attributi persistenti (iniziano con $@)
--
-- Description:	Ritorna il RICOVERO XML formato SOLE
--					Copiata da [dbo].[GetEventoXmlForSole]
-- =============================================
CREATE FUNCTION [sole].[OttieneRicoveroXml]
(
 @AziendaErogante VARCHAR(16)
,@NumeroNosologico VARCHAR(64)
)
RETURNS XML
AS
BEGIN 

	DECLARE @XmlRicovero AS XML
		
	IF NOT NULLIF(@AziendaErogante, '') IS NULL AND NOT NULLIF(@NumeroNosologico, '') IS NULL
	BEGIN
		--
		-- Eventi 2019-02-17
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
																	, 'IdEsternoPaziente', 'CodiceSanitario', 'Sesso'
																	, 'Cognome','Nome','DataNascita','CodiceFiscale')
												AND NOT Attributo.Valore IS NULL

												-- 2020-12-29 Non restituisco gli attributi persistenti
												AND NOT Attributo.Nome LIKE '$@%'
												AND NOT Attributo.Nome LIKE 'Sole-%'

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

		--
		-- Attributi Ricovero
		--
		DECLARE @XmlAttributiRicovero AS XML
		SET @XmlAttributiRicovero = (
				CONVERT(XML, (
							SELECT [sole].[NomeAttributoCodifica](REPLACE(Attributo.Nome, 'Ric@', '')) AS Nome
									, Attributo.Valore
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
		-- Ricovero dell'Evento
		--
		SET @XmlRicovero = (
				CONVERT(XML, (
							SELECT [Id], [IdEsterno]
								,[DataInserimento], [DataModifica]
								,[AziendaErogante], [SistemaErogante]

								,[StatoCodice]
								,CASE StatoCodice 
										WHEN 0 THEN 'Prenotazione'
										WHEN 1 THEN 'Accettazione'
										WHEN 2 THEN 'In reparto'
										WHEN 3 THEN 'Dimissione'
										WHEN 4 THEN 'Riapertura'
										WHEN 5 THEN 'Cancellazione'
										WHEN 255 THEN 'Incompleto'
										ELSE 'Stato sconosciuto'
									END AS StatoDescrizione
									
								,[TipoRicoveroCodice], NULLIF([TipoRicoveroDescr], '') AS [TipoRicoveroDescrizione]

								-- Al momento non ho i codici diagnosi
								,CONVERT(VARCHAR(64), NULL) AS DiagnosiCodice
								,[Diagnosi] AS DiagnosiDescrizione
								,CONVERT(VARCHAR(1024), NULL) AS DiagnosiDescrizioneLibera

								,[DataAccettazione], [DataDimissione]
								,SUBSTRING([RepartoAccettazioneCodice] + '00', 1, 5) AS [RepartoAccettazioneCodice]
								,[RepartoAccettazioneDescr] AS [RepartoAccettazioneDescrizione]
								
								,CASE WHEN NOT [DataDimissione] IS NULL THEN SUBSTRING([RepartoCodice] + '00', 1, 5)
									ELSE NULL END AS [RepartoDimissioneCodice]
								,CASE WHEN NOT [DataDimissione] IS NULL THEN [RepartoDescr]
									ELSE NULL END AS [RepartoDimissioneDescrizione]
								
								,[DataTrasferimento]
								,[OspedaleCodice], [OspedaleDescr] AS [OspedaleDescrizione]
								,[RepartoCodice], [RepartoDescr] AS [RepartoDescrizione]
								,[SettoreCodice], [SettoreDescr] AS [SettoreDescrizione]
								,[LettoCodice], CONVERT(VARCHAR(64), NULL) AS [LettoDescrizione]
								
								,@XmlAttributiRicovero AS Attributi
								--
								-- Eventi 2019-02-17
								--
								,@XmlEventi AS Eventi

							  FROM [store].[RicoveriBase] AS Ricovero
							  WHERE [NumeroNosologico] = @NumeroNosologico
								AND [AziendaErogante] = @AziendaErogante
							FOR XML AUTO, ELEMENTS
							))
						)
						
	END

	RETURN @XmlRicovero
END