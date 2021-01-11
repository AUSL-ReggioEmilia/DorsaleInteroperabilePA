-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-05-10
-- Modify date: 
-- Description:	Processa e annulla Referti ancora da inviare
-- =============================================
CREATE PROCEDURE [sole].[CodaRefertiRimuoveDaInviare]
	 @IdReferto UNIQUEIDENTIFIER
	,@Operazione INT
	,@StatoRichiestaCodice TINYINT
	,@AziendaErogante AS VARCHAR(64)
	,@SistemaErogante AS VARCHAR(64)
	,@NumeroNosologico AS VARCHAR(64)
	,@TipologiaSole AS VARCHAR(16)
AS
BEGIN

	SET NOCOUNT ON

	--
	--	Se @StatoCodice = Cancellazione non invio i precedenti (1 = ANNULLATO 2 = CANCELLATO)
	--
	DECLARE @Motivo VARCHAR(64) = NULL
	DECLARE @RecordTable TABLE (Id INT)
	DECLARE @RecordRimossi XML = NULL

	IF @StatoRichiestaCodice = 3 OR @Operazione = 2
	BEGIN
		--
		-- Non invio precedente, rimuovo dalla coda (salvo in altra)
		-- Cancellazione singolo Referto
		--
		SET @Motivo = CASE WHEN @StatoRichiestaCodice = 3 THEN 'Stato Annullato'
							WHEN @Operazione = 2 THEN 'Operazione Cancellato'
							ELSE 'Aggiornamento' END
		--
		-- Seleziono da RIMUOVERE
		--
		INSERT INTO @RecordTable
			SELECT IdSequenza
			FROM [sole].[CodaReferti] Referto
			WHERE [IdReferto] = @IdReferto
			ORDER BY [IdSequenza]

	END ELSE BEGIN
		--
		-- Non invio precedenti, rimuovo dalla coda e salvo in altra
		-- Aggiornamento singolo Referto
		--
		SET @Motivo = 'Aggiornamento - TipologiaSole=' + @TipologiaSole
		--
		-- Seleziono da RIMUOVERE
		--
		IF @TipologiaSole = 'LED'
		BEGIN
			--
			-- Per le Lettere di Dimissioni cerco per Nosologico e stesso sistema
			-- Invio solo l'ultima, i trasferimenti non interessano
			--
			INSERT INTO @RecordTable
				SELECT IdSequenza
				FROM [sole].[CodaReferti] Referto
				WHERE [NumeroNosologico] = @NumeroNosologico
					AND [AziendaErogante] = @AziendaErogante
					AND [SistemaErogante] = @SistemaErogante
				ORDER BY [IdSequenza]

		END ELSE BEGIN
			--
			-- Per i referti normali cerco per IdReferto
			--
			INSERT INTO @RecordTable
				SELECT IdSequenza
				FROM [sole].[CodaReferti] Referto
				WHERE [IdReferto] = @IdReferto
				ORDER BY [IdSequenza]
		END
	END

	------------------------------------------------------------------------------------
	-- Controllo Referti precedenti da rimuovere
	------------------------------------------------------------------------------------

	IF EXISTS (SELECT * FROM @RecordTable) AND NOT @Motivo IS NULL
	BEGIN

		SET @RecordRimossi = (SELECT *
						FROM [sole].[CodaReferti] Referto
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
			INSERT INTO [sole].[CodaRefertiRimossi]([Record], [IdReferto], [Motivo])
			VALUES (@RecordCompress, @IdReferto, @Motivo)

			DELETE FROM [sole].[CodaReferti]
			WHERE IdSequenza IN (SELECT rt.Id FROM @RecordTable rt)
		END
	END

END