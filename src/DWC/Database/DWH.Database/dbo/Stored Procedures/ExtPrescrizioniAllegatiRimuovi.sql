

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-03
-- Modify date: 2016-08-10 Sandro: Tabella split data e attributi senza campo XML
--									Usa tabella PrescrizioneBase
-- Description:	Rimuove un allegato della prescrizione
-- =============================================
CREATE PROCEDURE [dbo].[ExtPrescrizioniAllegatiRimuovi](
 @IdPrescrizione		uniqueidentifier
,@DataPartizione		smalldatetime
,@IdEsternoAllegato	varchar (64) = NULL
)
AS
BEGIN

SET NOCOUNT ON

DECLARE @NumRecord int
DECLARE @Err int


	BEGIN TRANSACTION

	IF NOT @IdEsternoAllegato IS NULL
	BEGIN
		-- Cancella singola prestazione

		-- Prima gli attributi
		DELETE [store].[PrescrizioniAllegatiAttributi]
		FROM [store].[PrescrizioniAllegatiAttributi] attr INNER JOIN [store].[PrescrizioniAllegatiBase] base
				ON base.[ID] = attr.[IdPrescrizioniAllegatiBase] AND base.[DataPartizione] = attr.[DataPartizione]
		WHERE base.[IdPrescrizioniBase] = @IdPrescrizione
			AND base.[DataPartizione] = @DataPartizione
			AND base.[IdEsterno] = @IdEsternoAllegato 

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT
	
		-- Poi la Base
		DELETE FROM [store].[PrescrizioniAllegatiBase]
		WHERE [IdPrescrizioniBase] = @IdPrescrizione
			AND [DataPartizione] = @DataPartizione
			AND [IdEsterno] = @IdEsternoAllegato 

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

	END	ELSE BEGIN
		-- Cancella tutte le prestazioni

		-- Prima gli attributi
		DELETE [store].[PrescrizioniAllegatiAttributi]
		FROM [store].[PrescrizioniAllegatiAttributi] attr INNER JOIN [store].[PrescrizioniAllegatiBase] base
				ON base.[ID] = attr.[IdPrescrizioniAllegatiBase] AND base.[DataPartizione] = attr.[DataPartizione]
		WHERE base.[IdPrescrizioniBase] = @IdPrescrizione
			AND base.[DataPartizione] = @DataPartizione

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT
	
		-- Poi la Base
		DELETE FROM [store].[PrescrizioniAllegatiBase]
		WHERE [IdPrescrizioniBase] = @IdPrescrizione
			AND [DataPartizione] = @DataPartizione 

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT
	END
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
    ON OBJECT::[dbo].[ExtPrescrizioniAllegatiRimuovi] TO [ExecuteExt]
    AS [dbo];

