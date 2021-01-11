/*
Rimuove l'allegato

MODIFICATO SANDRO 2015-08-19: Usa VIEW store
MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetPrescrizioniPk()
								Nella JOIN anche DataPartizione
								Legge @NumRecord e @Err contemporaneamente
*/
CREATE PROCEDURE [dbo].[ExtAllegatiRimuovi](
	@IdEsternoReferto as varchar(64),
	@IdEsterno as varchar(64) = NULL
)
AS
BEGIN

SET NOCOUNT ON

DECLARE @IdRefertiBase as uniqueidentifier
DECLARE @DataPartizione smalldatetime
DECLARE @NumRecord int
DECLARE @Err int

	-- Legge la PK del referto
	SELECT @IdRefertiBase = ID, @DataPartizione = DataPartizione
		FROM [dbo].[GetRefertiPk](RTRIM(@IdEsternoReferto))

	IF @IdRefertiBase IS NULL
	BEGIN
		-- Esce se no referto
		SELECT NULL
		RAISERROR('Errore referto non trovato!', 16, 1)
		RETURN 1001
	END

	BEGIN TRANSACTION

	IF NOT @IdEsterno IS NULL
	BEGIN
		-- Cancella singola prestazione
		
		--Rimuovo attributi
		DELETE store.AllegatiAttributi
		FROM store.AllegatiAttributi INNER JOIN store.AllegatiBase
			ON AllegatiAttributi.IdAllegatiBase = AllegatiBase.ID
				AND AllegatiAttributi.DataPartizione = AllegatiBase.DataPartizione
		WHERE  AllegatiBase.IdRefertiBase = @IdRefertiBase
			AND AllegatiBase.IdEsterno = @IdEsterno 
			AND AllegatiBase.DataPartizione = @DataPartizione 

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

		--Rimuovo base
		DELETE FROM store.AllegatiBase
		WHERE IdRefertiBase = @IdRefertiBase
			AND IdEsterno = @IdEsterno 
			AND DataPartizione = @DataPartizione

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT
	END
	ELSE
	BEGIN
		-- Cancella tutte le prestazioni
		--
		-- Rimuovo attributi
		DELETE store.AllegatiAttributi
		FROM store.AllegatiAttributi INNER JOIN store.AllegatiBase
			ON AllegatiAttributi.IdAllegatiBase = AllegatiBase.ID
				AND AllegatiAttributi.DataPartizione = AllegatiBase.DataPartizione
		WHERE  AllegatiBase.IdRefertiBase = @IdRefertiBase
			AND AllegatiBase.DataPartizione = @DataPartizione 

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

		--Rimuovo base
		DELETE FROM store.AllegatiBase
		WHERE IdRefertiBase = @IdRefertiBase
			AND DataPartizione = @DataPartizione 

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT
	END
	---------------------------------------------------
	--     Completato
	---------------------------------------------------

	COMMIT
	SELECT DELETED_COUNT=@NumRecord
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	IF @@TRANCOUNT > 0
		ROLLBACK
	
	SELECT DELETED_COUNT=0
	RETURN 1
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtAllegatiRimuovi] TO [ExecuteExt]
    AS [dbo];

