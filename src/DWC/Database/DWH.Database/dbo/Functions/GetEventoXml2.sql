


CREATE FUNCTION [dbo].[GetEventoXml2]
(@Id UNIQUEIDENTIFIER)
RETURNS XML
AS  
BEGIN 
/*
 Ritorna un segmento XML di tutto l'Evento
	namespace = http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0
	
	2012-07-11: Aggiunto noto Ricovero
	Modificata ETTORE 2012-09-17: traslazione dell'IdPaziente nell'IdPaziente attivo
	Modificata ETTORE 2013-06-05: Gestione "Prenotazione" 
		-Gestione della descrizione degli stati per comprendere anche gli stati della "Prenotazione"
		-Aggiunto nuovi stati per la "Prenotazione": 20,21,22,23,24
		-Aggiunto nuovo stato con valore 254="Stato Sconosciuto": aggiunto nel filtro where
		-Ora si usa tabella d3egli stati + function per determinare la descrizione associata allo stato
		
	ATTENZIONE: Gli eventi di lista di attesa hanno sempre i dati anagrafici negli attributi (anche quelli di ricovero dal 2013-06-05)
		Per gli eventi di ricovero li cerco sempre nell'evento 'A' di accettazione per compatibilità.

	Modificata SANDRO 2015-08-19: Usa le VIEW store. Invece di AllegatiBase usa Allegati che gestisce MineDataCompresso
													Prestazioni e Referti usate per ottimizare accesso agli attributi
	Modificata SANDRO 2017-09-05: Nuovi attributi di OSCURAMENTO e modificata query altri attributi aggiuntivi
	Modificata SANDRO 2019-02-19: Eventi del ricovero
	Modificata SANDRO 2019-04-05 Aggiunta filtro Evento.StatoCodice = 0 a lista degli eventi
	Modificata ETTORE 2019-12-13: Escludo la restituzione dell'evento fittizio LA dalla lista degli eventi di un ricovero 
	Modificata il: 2020-12-29: SANDRO - Non restituisco gli attributi persistenti

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
		DECLARE @IdEventoConAnagrafica as uniqueidentifier
		DECLARE @TipoEventoCodice as VARCHAR(16)
		
		SELECT @AziendaErogante=AziendaErogante
				, @NumeroNosologico=NumeroNosologico
				, @TipoEventoCodice = TipoEventoCodice
		FROM store.EventiBase WHERE Id = @Id
		--
		-- Inizializzo e ricavo l'Id dell'evento nei cui attributi sono presenti gli attributi anagrafici
		--
		SET @IdEventoConAnagrafica = @Id
		--
		-- Se Eventi ADT - ricovero cerco il record di accettazione per compatibilità
		-- Se Eventi ADT - lista di attesa posso subito usare qualsiasi evento 
		--
		IF @TipoEventoCodice = 'A' OR @TipoEventoCodice = 'T' OR @TipoEventoCodice = 'D' 
			OR @TipoEventoCodice = 'M' OR @TipoEventoCodice = 'X' OR @TipoEventoCodice = 'R' 
			OR @TipoEventoCodice = 'E'
		BEGIN
			IF @TipoEventoCodice <> 'A'
			BEGIN
				SELECT TOP 1
					@IdEventoConAnagrafica = Id
				FROM store.EventiBase WHERE AziendaErogante=@AziendaErogante 
										AND NumeroNosologico = @NumeroNosologico
											AND StatoCodice=0 AND TipoEventoCodice = 'A'
			END	
		END
		--
		-- Creo attributi Evento	
		--
		DECLARE @TipoEpisodioCodice VARCHAR(16)
		DECLARE @TipoEpisodioDescrizione VARCHAR(64)
		DECLARE @RepartoCodice VARCHAR(16)
		DECLARE @RepartoDescrizione VARCHAR(64)
		DECLARE @Diagnosi VARCHAR(8000)
		--
		-- Attributi per oscuramenti
		--
		DECLARE @OscuramentoMassivo VARCHAR(8000) = NULL
		DECLARE @OscuramentoPuntuale BIT = 0
		DECLARE @OscuramentoPaziente BIT = 0
		DECLARE @Oscurato BIT = 0

		SELECT @TipoEpisodioCodice = TipoEpisodio
			 , @TipoEpisodioDescrizione = NULLIF(dbo.GetEventiTipoEpisodioDesc(NULL, CONVERT(VARCHAR(16), TipoEpisodio), NULL), '')
			 , @RepartoCodice = RepartoCodice
			 , @RepartoDescrizione = RepartoDescr
			 , @Diagnosi = Diagnosi

			 , @OscuramentoMassivo = dbo.GetEventoOscuramentiString(AziendaErogante, NumeroNosologico)
			 , @OscuramentoPuntuale = dbo.GetEventoOscuramentiPuntuali(AziendaErogante, NumeroNosologico)
			 , @OscuramentoPaziente = CASE WHEN EXISTS (SELECT * FROM PazientiCancellati  
														WHERE PazientiCancellati.IdPazientiBase = IdPaziente
														AND PazientiCancellati.IdRepartiEroganti IS NULL)
										THEN 1 ELSE 0 END

		FROM store.Eventi where Id = @Id

		IF NOT @OscuramentoMassivo IS NULL OR @OscuramentoPuntuale = 1 OR @OscuramentoPaziente = 1
			SET @Oscurato = 1
		--
		-- Aggiungo a tabella temporanea
		--
		DECLARE @TableAttibutiEventi AS TABLE (Nome VARCHAR(64), Valore SQL_VARIANT )
		INSERT INTO @TableAttibutiEventi (Nome, Valore) VALUES ('TipoEpisodioCodice', @TipoEpisodioCodice)
		INSERT INTO @TableAttibutiEventi (Nome, Valore) VALUES ('TipoEpisodioDescrizione', @TipoEpisodioDescrizione)
		INSERT INTO @TableAttibutiEventi (Nome, Valore) VALUES ('RepartoCodice', @RepartoCodice)
		INSERT INTO @TableAttibutiEventi (Nome, Valore) VALUES ('RepartoDescrizione', @RepartoDescrizione)
		INSERT INTO @TableAttibutiEventi (Nome, Valore) VALUES ('Diagnosi', @Diagnosi)

		IF @Oscurato = 1
		BEGIN
			INSERT INTO @TableAttibutiEventi (Nome, Valore) VALUES ('Oscurato', CASE WHEN @Oscurato = 1 THEN 'SI' ELSE 'NO' END)
			INSERT INTO @TableAttibutiEventi (Nome, Valore) VALUES ('OscuratoCodici', @OscuramentoMassivo)
			INSERT INTO @TableAttibutiEventi (Nome, Valore) VALUES ('OscuratoMassivo', CASE WHEN NOT @OscuramentoMassivo IS NULL THEN 'SI' ELSE 'NO' END)
			INSERT INTO @TableAttibutiEventi (Nome, Valore) VALUES ('OscuratoPuntuale',  CASE WHEN @OscuramentoPuntuale = 1 THEN 'SI' ELSE 'NO' END)
			INSERT INTO @TableAttibutiEventi (Nome, Valore) VALUES ('OscuratoPaziente', CASE WHEN @OscuramentoPaziente = 1 THEN 'SI' ELSE 'NO' END)
		END
		--
		-- Attributi Evento
		--
		DECLARE @XmlAttributiEvento AS XML
		SET @XmlAttributiEvento = (
				CONVERT(XML, ( SELECT Nome, Valore FROM 
									(SELECT Nome, Valore
									FROM @TableAttibutiEventi
									
									UNION ALL
									
									SELECT Attributo.Nome, Attributo.Valore
									FROM store.EventiAttributi AS Attributo
											INNER JOIN store.EventiBase AS Evento
										ON Attributo.IdEventiBase = Evento.Id
											AND Attributo.DataPartizione = Evento.DataPartizione
									WHERE Evento.Id = @ID
										--escludo attributi del paziente
										AND NOT [Nome] IN ('CodiceAnagraficaCentrale','NomeAnagraficaCentrale'
													, 'IdEsternoPaziente', 'CodiceSanitario'
													, 'Cognome','Nome','DataNascita','CodiceFiscale')
										--escludo gli attributi aggiunti
										AND NOT EXISTS (SELECT * FROM @TableAttibutiEventi ta WHERE ta.Nome = Attributo.Nome)

										-- 2020-12-29 Non restituisco gli attributi persistenti
										AND (NOT Attributo.Nome LIKE '$@%')

									) Attributo
							WHERE NOT Attributo.Valore IS NULL
							ORDER BY  Attributo.Nome
							FOR XML AUTO
							)) 
						)
		--
		-- Attributi Ricovero
		--
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
		-- Eventi del ricovero 2019-02-19
		--
		DECLARE @XmlEventiRicovero AS XML
		SET @XmlEventiRicovero = (
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
										--2019-12-13: Escludo la restituzione dell'evento fittizio LA dalla lista degli eventi di un ricovero 
										AND Evento.TipoEventoCodice <> 'LA'
							ORDER BY  Evento.DataEvento
							FOR XML AUTO, ELEMENTS
							)) 
						)						
		--
		-- Ricovero dell'Evento
		--
		DECLARE @XmlRicovero AS XML
		SET @XmlRicovero = (
				CONVERT(XML, (
							SELECT [Id], [IdEsterno]
								,[DataInserimento], [DataModifica]
								,[AziendaErogante], [SistemaErogante]

								,[StatoCodice]
								,dbo.GetRicoveriStatiDescrizione([StatoCodice]) AS StatoDescrizione
									
								,[TipoRicoveroCodice], NULLIF([TipoRicoveroDescr], '') AS [TipoRicoveroDescrizione]

								-- Al momento non ho i codici diagnosi
								,CONVERT(VARCHAR(64), NULL) AS DiagnosiCodice
								,[Diagnosi] AS DiagnosiDescrizione
								,CONVERT(VARCHAR(1024), NULL) AS DiagnosiDescrizioneLibera

								,[DataAccettazione], [DataDimissione]
								,[RepartoAccettazioneCodice], [RepartoAccettazioneDescr] AS [RepartoAccettazioneDescrizione]
								,CASE WHEN NOT [DataDimissione] IS NULL THEN [RepartoCodice] ELSE NULL END AS [RepartoDimissioneCodice]
								,CASE WHEN NOT [DataDimissione] IS NULL THEN [RepartoDescr] ELSE NULL END AS [RepartoDimissioneDescrizione]
								
								,[DataTrasferimento]
								,[OspedaleCodice], [OspedaleDescr] AS [OspedaleDescrizione]
								,[RepartoCodice], [RepartoDescr] AS [RepartoDescrizione]
								,[SettoreCodice], [SettoreDescr] AS [SettoreDescrizione]
								,[LettoCodice], CONVERT(VARCHAR(64), NULL) AS [LettoDescrizione]
								
								,@XmlAttributiRicovero AS Attributi
								--
								-- 2019-02-19
								--
								,@XmlEventiRicovero AS Eventi

							  FROM [store].[RicoveriBase] AS Ricovero
							  WHERE [NumeroNosologico] = @NumeroNosologico
								AND [AziendaErogante] = @AziendaErogante
							FOR XML AUTO, ELEMENTS
							))
						)
						
		--
		-- Evento
		--	
		;WITH XMLNAMESPACES ('http://schemas.progel.it/SQL/Dwh/QueueEventoOutput/1.0' as ns0)
		SELECT @XmlEvento = (
			SELECT "ns0:Evento".Id, "ns0:Evento".IdEsterno
				,dbo.GetPazienteAttivoByIdSac("ns0:Evento".IdPaziente) AS IdPaziente
				-- Ricavo CodiceAnagraficaCentrale e NomeAnagraficaCentrale
				,CAST(dbo.GetEventiAttributo(@IdEventoConAnagrafica, 'CodiceAnagraficaCentrale') AS VARCHAR(64)) AS CodiceAnagraficaCentrale
				,CAST(dbo.GetEventiAttributo(@IdEventoConAnagrafica, 'NomeAnagraficaCentrale') AS VARCHAR(64)) AS NomeAnagraficaCentrale
				
				-- Ricavo paziente da SAC
				,dbo.GetSacPazienteXmlById(dbo.GetPazienteAttivoByIdSac("ns0:Evento".IdPaziente)) AS Paziente		
						
				,"ns0:Evento".DataInserimento, "ns0:Evento".DataModifica
				,"ns0:Evento".AziendaErogante, "ns0:Evento".SistemaErogante
				
				,"ns0:Evento".DataEvento
				,"ns0:Evento".TipoEventoCodice, "ns0:Evento".TipoEventoDescr AS TipoEventoDescrizione
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
