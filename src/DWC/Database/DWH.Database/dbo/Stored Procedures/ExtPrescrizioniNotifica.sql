-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-13
-- Modify date: 2017-04-13 Processa il parsing HL7 spostato in ottieni prima dell'invio
-- Description:	Aggiunge La notifica nella coda
-- =============================================
CREATE PROCEDURE [dbo].[ExtPrescrizioniNotifica](
 @IdPrescrizione uniqueidentifier
,@DataPartizione smalldatetime
,@Operazione int
) AS
BEGIN

DECLARE @NumRecord int
DECLARE @Err int

	SET NOCOUNT ON

	BEGIN TRAN

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	DECLARE @TimeoutCorrelazione INT
	SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput', 'TimeoutCorrelazione'), 1)
	--
	--Notifico
	--
	INSERT INTO CodaPrescrizioniOutput (IdPrescrizione, Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
	VALUES(@IdPrescrizione, @Operazione , 'SOLE', @TimeoutCorrelazione, 0, dbo.GetPrescrizioneXml(@IdPrescrizione))

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--     Completato
	---------------------------------------------------

	COMMIT
	SELECT INSERTED_COUNT = @NumRecord
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	IF @@TRANCOUNT > 0
		ROLLBACK

	SELECT INSERTED_COUNT = 0
	RETURN 1
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtPrescrizioniNotifica] TO [ExecuteExt]
    AS [dbo];

