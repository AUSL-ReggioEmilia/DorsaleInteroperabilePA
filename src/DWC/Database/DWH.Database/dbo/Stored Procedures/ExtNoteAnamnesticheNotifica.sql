

-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-30
-- Description:	Aggiunge La notifica della nota anamnestica nella coda
--				Leggo il valore della correlazione da una function
--				Se alla SP viene passato @TipoNotifica = 0 significa che non si deve inserire nella coda di notifica perchè la notifica la fa DIRETTAMENTE l'orchestrazione
--				e si inserisce in CodaNoteAnamnesticheOutputInviati
--				Se alla SP viene passato @TipoNotifica = 1 significa che si deve inserire nella coda CodaNoteAnamnesticheOutput; la notifica verrà fatta da BT tramite lettura della coda di output
-- =============================================
CREATE PROCEDURE [dbo].[ExtNoteAnamnesticheNotifica](
	@IdEsterno				VARCHAR(64)
	, @IdNotaAnamnestica	UNIQUEIDENTIFIER
	, @AziendaErogante		VARCHAR(16)
	, @SistemaErogante		VARCHAR(16)
	, @Operazione			INT --0=Inserimento nota anamnestica, 1=Aggiornamento nota anamnestica, 2=Cancellazione nota anamnestica
	, @XmlNotaAnamnestica	XML --passo l'xml restituito dalla SO ExtNoteAnamnesticheAggiungi, cosi non lo devo rileggere
	, @TipoNotifica int
) AS
BEGIN

	DECLARE @NumRecord int
	DECLARE @Err int
	DECLARE @IdCorrelazione AS VARCHAR(64)

	SET NOCOUNT ON

	BEGIN TRAN

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	DECLARE @TimeoutCorrelazione INT
	SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput', 'TimeoutCorrelazione'), 1)


	SET @IdCorrelazione = [dbo].[GetCodaNoteAnamnesticheOutputIdCorrelazione](@AziendaErogante, @SistemaErogante, @IdEsterno)
	--
	-- Notifico
	--
	IF @TipoNotifica = 1
	BEGIN
		INSERT INTO CodaNoteAnamnesticheOutput (IdNotaAnamnestica, Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
		VALUES(@IdNotaAnamnestica, @Operazione , @IdCorrelazione, @TimeoutCorrelazione, 0, @XmlNotaAnamnestica)
	END
	ELSE
	BEGIN
		--
		-- Non avendo l'IdSequenza l'ho valorizzato con 0...(in questo modo si può capire che il record non è passato per la CodaNoteAnamnesticheOutput)
		--
		INSERT INTO [dbo].[CodaNoteAnamnesticheOutputInviati](IdSequenza, DataInserimento, IdNotaAnamnestica, Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, MessaggioCompresso)
		VALUES (0, GETUTCDATE(), @IdNotaAnamnestica, @Operazione, @IdCorrelazione, @TimeoutCorrelazione, 0, dbo.compress(CONVERT(VARBINARY(MAX), @XmlNotaAnamnestica)))
	END

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
    ON OBJECT::[dbo].[ExtNoteAnamnesticheNotifica] TO [ExecuteExt]
    AS [dbo];

