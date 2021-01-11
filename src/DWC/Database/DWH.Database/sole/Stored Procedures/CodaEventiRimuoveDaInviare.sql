

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-05-10
-- Modify date: 2019-05-16 - Se evento A rimuovo gli E in coda
-- Modify date: 2019-05-20 - Azioni su eventi solo se non di Annullato o Cancellati
--								Eseguo anche controllo di aggiornamento dopo azioni
--
-- Description:	Processa e annulla eventi ancora da inviare
-- =============================================
CREATE PROCEDURE [sole].[CodaEventiRimuoveDaInviare]
	 @IdEvento UNIQUEIDENTIFIER
	,@Operazione INT
	,@StatoCodice TINYINT
	,@TipoEventoCodice VARCHAR(1)
	,@AziendaErogante AS VARCHAR(64)
	,@SistemaErogante AS VARCHAR(64)
	,@NumeroNosologico AS VARCHAR(64)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @Motivo VARCHAR(64) = NULL
	DECLARE @RecordTable TABLE (Id INT)
	DECLARE @RecordRimossi XML = NULL
	--
	--	Se @StatoCodice = Cancellazione non invio i precedenti (1 = ANNULLATO 2 = CANCELLATO)
	--
	IF @StatoCodice IN (1, 2) OR @Operazione = 2
	BEGIN
		--
		-- Non invio precedente, rimuovo dalla coda (salvo in altra)
		-- Cancellazione singolo evento
		--
		SELECT @Motivo = CASE WHEN @StatoCodice = 1 THEN 'Stato Annullato'
							WHEN @StatoCodice = 2 THEN 'Stato Cancellato'
							WHEN @Operazione = 2 THEN 'Operazione Cancellato'
							ELSE NULL END
		--
		-- Seleziono da RIMUOVERE
		--
		INSERT INTO @RecordTable
			SELECT IdSequenza
			FROM [sole].[CodaEventi] Evento
			WHERE [IdEvento] = @IdEvento
			ORDER BY [IdSequenza]

	END ELSE BEGIN
		--
		---------------------------------------------------------------
		-- Azioni per limitare eventi rindondanti o inutili
		---------------------------------------------------------------
		--
		--	Se @TipoEventoCodice = E non invio precedenti tipo = tutti
		--	Se @TipoEventoCodice = X non invio precedenti tipo = A T D
		--	Se @TipoEventoCodice = R non invio precedenti tipo = D
		--	Se @TipoEventoCodice = A non invio precedenti tipo = E

		IF @TipoEventoCodice = 'E'
		BEGIN
			--
			-- Non invio precedenti, rimuovo dalla coda (salvo in altra)
			-- Tutti gli eventi del ricovere
			--
			SET @Motivo = 'Evento E - Cancella'
			--
			-- Seleziono da RIMUOVERE
			--
			INSERT INTO @RecordTable
				SELECT IdSequenza
				FROM [sole].[CodaEventi] Evento
				WHERE [NumeroNosologico] = @NumeroNosologico
					AND [AziendaErogante] = @AziendaErogante
					AND [SistemaErogante] = @SistemaErogante
				ORDER BY [IdSequenza]

		END ELSE IF @TipoEventoCodice = 'X'
		BEGIN
			--
			-- Non invio precedenti, rimuovo dalla coda (salvo in altra)
			-- Gli eventi del ricovere A T D
			--
			SET @Motivo = 'Evento X - Annulla'
			--
			-- Seleziono da RIMUOVERE
			--
			INSERT INTO @RecordTable
				SELECT IdSequenza
				FROM [sole].[CodaEventi] Evento
				WHERE [NumeroNosologico] = @NumeroNosologico
					AND [AziendaErogante] = @AziendaErogante
					AND [SistemaErogante] = @SistemaErogante
					AND [TipoEventoCodice] IN ('A', 'T', 'D')
				ORDER BY [IdSequenza]

		END ELSE IF @TipoEventoCodice = 'R'
		BEGIN
			--
			-- Non invio precedenti, rimuovo dalla coda (salvo in altra)
			-- Gli eventi del ricovere D
			--
			SET @Motivo = 'Evento R - Riapertura'
			--
			-- Seleziono da RIMUOVERE
			--
			INSERT INTO @RecordTable
				SELECT IdSequenza
				FROM [sole].[CodaEventi] Evento
				WHERE [NumeroNosologico] = @NumeroNosologico
					AND [AziendaErogante] = @AziendaErogante
					AND [SistemaErogante] = @SistemaErogante
					AND [TipoEventoCodice] IN ('D')
				ORDER BY [IdSequenza]

		END ELSE IF @TipoEventoCodice = 'A'
		BEGIN
			--
			-- Non invio precedenti, rimuovo dalla coda (salvo in altra)
			-- Gli eventi del ricovere E
			--
			SET @Motivo = 'Evento A - Apertura'
			--
			-- Seleziono da RIMUOVERE
			--
			INSERT INTO @RecordTable
				SELECT IdSequenza
				FROM [sole].[CodaEventi] Evento
				WHERE [NumeroNosologico] = @NumeroNosologico
					AND [AziendaErogante] = @AziendaErogante
					AND [SistemaErogante] = @SistemaErogante
					AND [TipoEventoCodice] IN ('E')
				ORDER BY [IdSequenza]
		END
		--
		-- Rimuovo motivo se nessun record trovato nel processo eventi
		--
		IF NOT EXISTS (SELECT * FROM @RecordTable)
			SET @Motivo = NULL
		--
		-- Non invio precedenti, rimuovo dalla coda e salvo in altra
		-- Il singolo evento lo posso rimuovere solo se è l'ultimo del nosologico
		-- Questo per non modificare la sequenza degli eventi
		--
		-- Cerco ultimo per nosologico
		--
		DECLARE @Ultimo_IdSequenza INT
		DECLARE @Ultimo_TipoEventoCodice VARCHAR(1)

		SELECT TOP 1 @Ultimo_IdSequenza = [IdSequenza]
			,@Ultimo_TipoEventoCodice = [TipoEventoCodice]
		FROM [sole].[CodaEventi] Evento
		WHERE [NumeroNosologico] = @NumeroNosologico
			AND [AziendaErogante] = @AziendaErogante
			AND [SistemaErogante] = @SistemaErogante
		ORDER BY [IdSequenza] DESC
		--
		-- Seleziono da RIMUOVERE se l'ultimo
		--
		INSERT INTO @RecordTable
			SELECT IdSequenza
			FROM [sole].[CodaEventi] Evento
			WHERE [IdEvento] = @IdEvento
				AND [IdSequenza] = @Ultimo_IdSequenza
				AND @Ultimo_TipoEventoCodice = @TipoEventoCodice
			ORDER BY [IdSequenza]
		--
		-- Setto motivo se record trovati
		--
		IF @@ROWCOUNT > 0
			SET @Motivo = ISNULL(@Motivo + '+ ', '') + 'Aggiornamento ' + @TipoEventoCodice
	END

	------------------------------------------------------------------------------------
	-- Controllo eventi precedenti da rimuovere
	------------------------------------------------------------------------------------

	IF EXISTS (SELECT * FROM @RecordTable) AND NOT @Motivo IS NULL
	BEGIN

		SET @RecordRimossi = (SELECT *
						FROM [sole].[CodaEventi] Evento
						WHERE IdSequenza IN (SELECT rt.Id FROM @RecordTable rt)
						ORDER BY [IdSequenza]
						FOR XML AUTO, BINARY BASE64, ROOT('SoleCoda')
						)

		IF NOT @RecordRimossi IS NULL
		BEGIN
			--
			-- Comprimo i dati
			--
			DECLARE @RecordCompress VARBINARY(MAX)
			SET @RecordCompress = [dbo].[compress](CONVERT(VARBINARY(MAX), @RecordRimossi))
			--
			-- Sposto dalle coda
			--
			INSERT INTO [sole].[CodaEventiRimossi]([Record], [IdEvento], [Motivo])
			VALUES (@RecordCompress, @IdEvento, @Motivo)

			DELETE FROM [sole].[CodaEventi]
			WHERE IdSequenza IN (SELECT rt.Id FROM @RecordTable rt)
		END
	END

END