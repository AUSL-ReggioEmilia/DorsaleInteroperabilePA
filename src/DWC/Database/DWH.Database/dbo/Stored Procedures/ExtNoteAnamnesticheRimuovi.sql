




-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2018-06-12
-- Description:	Rimuove la note anamnestica
--				Prima della rimozione memorizza l'XML che descrive la nota anamnestica
--				 che verrà usato dall'orchestrazione per la notifica
-- =============================================
CREATE PROCEDURE [dbo].[ExtNoteAnamnesticheRimuovi]
(
	@IdNotaAnamnestica		uniqueidentifier
	, @DataPartizione		smalldatetime
	-----------------------------------------------
	, @XmlNotaAnamnestica	XML NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @NumRecord int
	DECLARE @Err int

	IF @IdNotaAnamnestica IS NULL
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT DELETED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdNotaAnamnestica)!', 16, 1)
		RETURN 1010
	END

	IF @DataPartizione IS NULL 
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT DELETED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@DataPartizione)!', 16, 1)
		RETURN 1011
	END

	--
	-- Memorizzo l'Xml della nota anamnestica
	--
	SET @XmlNotaAnamnestica = dbo.GetNotaAnamnesticaXml(@IdNotaAnamnestica, @Datapartizione) 

	--
	-- Inizio la transazione per la cancellazione
	--
	BEGIN TRANSACTION
	--
	-- Cancellazione da NoteAnamnesticheAttributi
	--
	DELETE FROM [store].[NoteAnamnesticheAttributi]
	WHERE [IdNoteAnamnesticheBase] = @IdNotaAnamnestica
		AND [DataPartizione] = @DataPartizione

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	--
	-- Cancellazione da NoteAnamnesticheBase
	--
	DELETE FROM [store].[NoteAnamnesticheBase]
	WHERE Id = @IdNotaAnamnestica
		AND DataPartizione = @DataPartizione

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT
	--
	-- Commit
	--
	COMMIT

	--
	-- Restituisco l'XML della nota anamnestica precedentemente calcolato
	--
	SELECT 
		DELETED_COUNT = @NumRecord

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
    ON OBJECT::[dbo].[ExtNoteAnamnesticheRimuovi] TO [ExecuteExt]
    AS [dbo];

