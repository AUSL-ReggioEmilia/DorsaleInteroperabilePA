/*
Rimuove il referto e suoi attributi

	Modifica Ettore 2013-03-05: tolto riferimenti a RefertiLog
	MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetRefertiPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]

*/
CREATE  PROCEDURE [dbo].[ExtRefertiRimuovi]
	@IdEsterno  varchar(64)
AS
BEGIN

DECLARE @IdRefertiBase uniqueidentifier
DECLARE @DataPartizione smalldatetime
DECLARE @NumRecord int
DECLARE @Err int

DECLARE @CancellazioneAbilitata int

	SET NOCOUNT ON
	--------------------------------------------------------------------------------------------------------
	--- Cerca IdReferto
	--------------------------------------------------------------------------------------------------------

	-- Legge la PK del referto
	SELECT @IdRefertiBase = ID, @DataPartizione = DataPartizione
	FROM [dbo].[GetRefertiPk](RTRIM(@IdEsterno))

	IF @IdRefertiBase IS NULL
	BEGIN
		--------------------------------------------------------------------------------------------------------
		--- Referto non trovato
		--------------------------------------------------------------------------------------------------------
		SELECT DELETED_COUNT=NULL
		RAISERROR('Errore Referto non trovato!', 16, 1)
		RETURN 1002
	END
	--
	-- 18/04/2012: Modifica Ettore gestione delle catene referti
	-- Implementazione controlli di cancellazione per catena
	-- 08/06/2012: Modifica Ettore uso di una function per determinare se referto è cancellabile
	--
	SELECT @CancellazioneAbilitata = dbo.GetRefertiCancellabile2(@IdEsterno,  @IdRefertiBase, @DataPartizione )

	IF @CancellazioneAbilitata > 0 
	BEGIN 
		BEGIN TRANSACTION

		------------------------------------------------------------------------------------------------------------
		--          Rimuovo RefertiBaseRiferimenti - Modifica Ettore 13/04/2012
		------------------------------------------------------------------------------------------------------------	
		DELETE FROM [store].RefertiBaseRiferimenti
		WHERE IdRefertiBase = @IdRefertiBase
			AND DataPartizione = @DataPartizione

		IF @@ERROR <> 0 GOTO ERROR_EXIT		

		------------------------------------------------------------------------------------------------------------
		--          Rimuovo attributi
		------------------------------------------------------------------------------------------------------------	

		DELETE FROM [store].RefertiAttributi
		WHERE IdRefertiBase = @IdRefertiBase
			AND DataPartizione = @DataPartizione

		IF @@ERROR <> 0 GOTO ERROR_EXIT

		------------------------------------------------------------------------------------------------------------
		--          Rimuovo base
		------------------------------------------------------------------------------------------------------------	

		DELETE FROM [store].RefertiBase
		WHERE Id = @IdRefertiBase
			AND DataPartizione = @DataPartizione

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

		---------------------------------------------------
		--     Completato
		---------------------------------------------------

		COMMIT
		SELECT DELETED_COUNT=@NumRecord
		RETURN 0
	END
	ELSE
	BEGIN
		--Non ho cancellato perche è una CATENA, ma OK non segnalo errore
		SELECT DELETED_COUNT=1
		RETURN 0
	END

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
    ON OBJECT::[dbo].[ExtRefertiRimuovi] TO [ExecuteExt]
    AS [dbo];

