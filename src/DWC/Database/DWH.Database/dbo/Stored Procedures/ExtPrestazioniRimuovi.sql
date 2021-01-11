/* 
Rimuove il referto e la prestazioni ad esso associate

MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetPrescrizioniPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]
*/
CREATE PROCEDURE [dbo].[ExtPrestazioniRimuovi](
	@IdEsternoReferto as varchar(64),
	@IdEsterno as varchar(64) = NULL
)
AS
BEGIN

DECLARE @IdRefertiBase uniqueidentifier
DECLARE @DataPartizione smalldatetime
DECLARE @NumRecord int
DECLARE @Err int

	SET NOCOUNT ON

	-- Legge la PK del referto
	SELECT @IdRefertiBase = ID, @DataPartizione = DataPartizione
		FROM [dbo].[GetRefertiPk](RTRIM(@IdEsternoReferto))

	IF @IdRefertiBase IS NULL
		BEGIN
			-- Esce se no referto
			SELECT DELETED_COUNT=NULL
			RAISERROR('Errore referto non trovato!', 16, 1)
			RETURN 1001
		END

	BEGIN TRANSACTION

	IF NOT @IdEsterno IS NULL
	BEGIN
		-- Cancella singola prestazione
			
		--Rimuovo attributi
		DELETE [store].PrestazioniAttributi
		FROM [store].PrestazioniAttributi INNER JOIN [store].PrestazioniBase
			ON PrestazioniAttributi.IdPrestazioniBase = PrestazioniBase.ID
				AND PrestazioniAttributi.DataPartizione = PrestazioniBase.DataPartizione
		WHERE  PrestazioniBase.IdRefertiBase = @IdRefertiBase
			AND PrestazioniBase.IdEsterno = @IdEsterno 
			AND PrestazioniBase.DataPartizione = @DataPartizione

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

		--Rimuovo base
		DELETE FROM [store].PrestazioniBase
		WHERE IdRefertiBase = @IdRefertiBase
			AND IdEsterno=@IdEsterno 
			AND DataPartizione = @DataPartizione

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

	END	ELSE BEGIN
		-- Cancella tutte le prestazioni
		--
		-- Rimuovo attributi
		DELETE [store].PrestazioniAttributi
		FROM [store].PrestazioniAttributi INNER JOIN [store].PrestazioniBase
			ON PrestazioniAttributi.IdPrestazioniBase = PrestazioniBase.ID
				AND PrestazioniAttributi.DataPartizione = PrestazioniBase.DataPartizione
		WHERE  PrestazioniBase.IdRefertiBase = @IdRefertiBase
			AND PrestazioniBase.DataPartizione = @DataPartizione

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

		--Rimuovo base
		DELETE FROM [store].PrestazioniBase
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
    ON OBJECT::[dbo].[ExtPrestazioniRimuovi] TO [ExecuteExt]
    AS [dbo];

