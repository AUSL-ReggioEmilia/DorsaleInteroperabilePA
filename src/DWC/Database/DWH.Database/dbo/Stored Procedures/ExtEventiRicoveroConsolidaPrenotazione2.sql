

-- =============================================
-- Author:		ETTORE
-- Create date: 2019-07-22
-- Description:	Nuova SP separata per il consolidamento del record di ricovero per una prenotazione
-- =============================================
--		Consolidamento del record di PRENOTAZIONE in base agli eventi di lista di attesa
--		Mi assicuro di prendere ultima notifica IL nella subquery che determina la data di accettazione
--		In caso contrario se vengono erroneamente inviate due notifiche IL senza un comando di chiusura/cancellazione:
--			-la subquery senza il TOP 1 va in errore ma non viene generata una eccezione
--			-la SP restituisce 0 record e la data access cancella il ricovero
-- =============================================
--	Ricavo i dati della lista di attesa dall'ultimo record di lista di attesa
--	Se non ci sono eventi validi allora restituisco quello che c'è nel ricovero con stato 254 (=Sconosciuto)
-- =============================================
-- Modify date: 2020-03-30 - ETTORE: eliminato il try catch cosi errore SQL arriva direttamente alla DAE
--									 e tolto nel codice della DAE il test reader.HasRow() perchè la 
--									 segnalazione dell'eccezione avviene in fase di lettura del reader.
CREATE PROCEDURE [dbo].[ExtEventiRicoveroConsolidaPrenotazione2]
(
	@AziendaErogante AS VARCHAR(16)
	, @NumeroNosologico AS  VARCHAR(64) --per eventi di lista di attesa questo è il codice della prenotazione
	, @RicoveroEsiste AS BIT
	, @IdEsternoEvento AS VARCHAR(64) = NULL --Id dell'evento corrente
)
AS
BEGIN
		DECLARE @UltimoEventoValido_Id UNIQUEIDENTIFIER
		DECLARE @UltimoEventoValido_IdEsterno VARCHAR(64)
		
		--
		-- Cerco ultimo evento 'IL', 'ML', 'DL', 'RL', 'SL'
		-- Uso DataModificaEsterno per ordinare
		--
		SELECT TOP 1
			@UltimoEventoValido_IdEsterno = IdEsterno
			, @UltimoEventoValido_Id = Id
		FROM
			store.EventiBase
		WHERE 
			AziendaErogante = @AziendaErogante
			AND NumeroNosologico = @NumeroNosologico
			--
			-- Si possonbo tenere 'RL', 'SL' se e solo se in questo tipo di notifiche vemgono comunque passati tutti i dati, come avviene per IL,ML,DL
			-- In particolare 'CodStatoPrenotazione', 'OspedaleCodice', 'OspedaleDescr', 'TipoEpisodioDescr'
			-- Prima comunque, si leggeva i dati dall'ultimo evento arrivato e poteva essere un RL o un SL.
			--
			AND StatoCodice = 0 AND TipoEventoCodice IN ('IL', 'ML', 'DL', 'RL', 'SL')
		ORDER BY
			DataModificaEsterno DESC 

		IF NOT @UltimoEventoValido_IdEsterno IS NULL 
		BEGIN
			SELECT 
				--Calcolo lo stato della lista di attesa basandomi sull'ultimo evento valido
				CASE 
					CONVERT(VARCHAR(1), dbo.GetEventiAttributo(Id, 'CodStatoPrenotazione'))
								WHEN '0' THEN 20 --IN ATTESA
								WHEN '1' THEN 21 --CHIAMATO
								WHEN '2' THEN 22 --RICOVERATO
								WHEN '3' THEN 23 --SOSPESO
								WHEN '4' THEN 24 --ANNULLATO
								ELSE 254		 --Sconosciuto
					END AS StatoCodice
				,(SELECT MAX(DataModificaEsterno) FROM store.EventiBase WHERE AziendaErogante = @AziendaERogante 
					AND NumeroNosologico = @NumeroNosologico 
					) 
					AS DataModificaEsterno
				, NumeroNosologico
				, AziendaErogante
				, CAST(NULL AS VARCHAR(64)) AS  RepartoErogante
				, IdPaziente
				, CONVERT(VARCHAR(16), dbo.GetEventiAttributo(Id, 'OspedaleCodice')) AS OspedaleCodice 
				, CONVERT(VARCHAR(128), dbo.GetEventiAttributo(Id, 'OspedaleDescr'))  AS OspedaleDescr 
				, TipoEpisodio AS TipoRicoveroCodice  --non cambia
				, dbo.GetEventiTipoEpisodioDesc(NULL , TipoEpisodio, CONVERT(VARCHAR(128), dbo.GetEventiAttributo(Id, 'TipoEpisodioDescr'))) AS TipoRicoveroDescr 
				, Diagnosi 
				--Cosa succede se l'evento IL viene cancellato? NON si trova la DataAccettazione che può essere NULL: OK!
				, (SELECT TOP 1 DataEvento FROM store.EventiBase 
											WHERE AziendaErogante = @AziendaErogante 
												AND NumeroNosologico = @NumeroNosologico 
												AND StatoCodice = 0 
												AND TipoEventoCodice = 'IL' 
											ORDER BY DataModificaEsterno DESC)  AS DataAccettazione
				, RepartoCodice AS RepartoAccettazioneCodice
				, RepartoDescr AS RepartoAccettazioneDescr
				, CAST(NULL AS DATETIME) AS DataTrasferimento
				, RepartoCodice AS RepartoCodice
				, RepartoDescr AS RepartoDescr
				, CAST(NULL AS VARCHAR(16)) AS SettoreCodice
				, CAST(NULL AS VARCHAR(128)) AS SettoreDescr
				, CAST(NULL AS VARCHAR(16)) AS LettoCodice
				--
				-- La data della chiusura della lista di attesa: la data dell'evento che setta lo stato a 2=RICOVERATO o 4=ANNULLATO
				-- Calcolo sull'ultimo evento arrivato la data dimissione che equivale alla DataEvento con determinato attributo 'CodStatoPrenotazione'
				--
				, CASE CONVERT(VARCHAR(1), dbo.GetEventiAttributo(Id, 'CodStatoPrenotazione'))
						WHEN '2' THEN DataEvento  -- 2=RICOVERATO
						WHEN '4' THEN DataEvento  -- 4=ANNULLATO
						ELSE CAST(NULL AS DATETIME)
				END AS DataDimissione
			FROM 
				store.EventiBase
			WHERE
				IdEsterno = @UltimoEventoValido_IdEsterno

			IF @@ERROR <> 0 GOTO ERROR_EXIT

		END
		ELSE
		BEGIN 
			--Non c'è nessun evento valido: restituisco i dati che c'erano sul record del ricovero
			--come fatto per i ricoveri standard
			SELECT 
				254 AS StatoCodice --Sconosciuto
				--Mi assicuro di avere la max datamodifica esterna
				,(SELECT MAX(DataModificaEsterno) FROM store.EventiBase WHERE AziendaErogante = @AziendaERogante 
					AND NumeroNosologico = @NumeroNosologico 
					) 
					AS DataModificaEsterno
				, NumeroNosologico
				, AziendaErogante
				, RepartoErogante
				, IdPaziente
				, OspedaleCodice 
				, OspedaleDescr 
				, TipoRicoveroCodice  
				, TipoRicoveroDescr 
				, Diagnosi 
				, DataAccettazione
				, RepartoAccettazioneCodice
				, RepartoAccettazioneDescr
				, DataTrasferimento
				, RepartoCodice
				, RepartoDescr
				, SettoreCodice
				, SettoreDescr
				, LettoCodice
				, DataDimissione
			FROM 
				store.RicoveriBase
			WHERE
				AziendaErogante = @AziendaERogante
				AND NumeroNosologico = @NumeroNosologico

			IF @@ERROR <> 0 GOTO ERROR_EXIT

		END 
		--
		--
		--
		RETURN 0

ERROR_EXIT:
	RETURN 1

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiRicoveroConsolidaPrenotazione2] TO [ExecuteExt]
    AS [dbo];

