


-- =============================================
-- Author:		ETTORE
-- Create date: 2019-02-22
-- Description:	Inserisce log per apire quali connettori non aggiungono il prefisso AziendaErogante
-- =============================================
CREATE PROCEDURE [dbo].[ExtLogAutoprefix]
(
	@AziendaErogante	varchar(16),
	@SistemaErogante	varchar(16),
	@RepartoErogante	varchar(64) = NULL, 
	@IdEsterno			varchar(64)
) AS
BEGIN
	SET NOCOUNT ON
	DECLARE @NumRecord integer
	DECLARE @Err int
	INSERT INTO [dbo].LogAutoprefix
	(
		AziendaErogante
		, SistemaErogante
		, RepartoErogante
		, IdEsterno
	)
	VALUES
	(
		@AziendaErogante
		, @SistemaErogante
		, @RepartoErogante
		, @IdEsterno
	)

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	SELECT INSERTED_COUNT=@NumRecord
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	SELECT INSERTED_COUNT=0
	RETURN 1

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtLogAutoprefix] TO [ExecuteExt]
    AS [dbo];

