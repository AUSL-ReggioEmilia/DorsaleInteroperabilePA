

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-03
-- Modify date: 2016-08-10 Sandro: Tabella split data e attributi senza campo XML
--									Usa tabella PrescrizioneBase
-- Description:	Rimuove la prescrizione e i suoi allegati
-- =============================================
CREATE PROCEDURE [dbo].[ExtPrescrizioniRimuovi](
 @IdPrescrizione		uniqueidentifier
,@DataPartizione		smalldatetime
)
AS
BEGIN

DECLARE @NumRecord int
DECLARE @Err int

	SET NOCOUNT ON

	IF @IdPrescrizione IS NULL
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdPrescrizione)!', 16, 1)
		RETURN 1010
	END

	IF @DataPartizione IS NULL 
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@DataPartizione)!', 16, 1)
		RETURN 1011
	END


	BEGIN TRANSACTION

	---------------------------------------------------
	--Allegati attributi
	DELETE [store].[PrescrizioniAllegatiAttributi]
	FROM [store].[PrescrizioniAllegatiAttributi] attr INNER JOIN [store].[PrescrizioniAllegatiBase] base
			ON base.[ID] = attr.[IdPrescrizioniAllegatiBase] AND base.[DataPartizione] = attr.[DataPartizione]
	WHERE base.[IdPrescrizioniBase] = @IdPrescrizione
		AND base.[DataPartizione] = @DataPartizione

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--Allegati
	DELETE FROM [store].[PrescrizioniAllegatiBase]
	WHERE IdPrescrizioniBase = @IdPrescrizione
		AND DataPartizione = @DataPartizione

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--Prescrizioni allegati
	DELETE FROM [store].[PrescrizioniAttributi]
	WHERE [IdPrescrizioniBase] = @IdPrescrizione
		AND [DataPartizione] = @DataPartizione

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT
	---------------------------------------------------
	--Prescrizioni
	DELETE FROM [store].[PrescrizioniBase]
	WHERE Id = @IdPrescrizione
		AND DataPartizione = @DataPartizione

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--     Completato
	---------------------------------------------------

	COMMIT
	SELECT DELETED_COUNT = @NumRecord
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	IF @@TRANCOUNT > 0
		ROLLBACK

	SELECT DELETED_COUNT = 0
	RETURN 1
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtPrescrizioniRimuovi] TO [ExecuteExt]
    AS [dbo];

