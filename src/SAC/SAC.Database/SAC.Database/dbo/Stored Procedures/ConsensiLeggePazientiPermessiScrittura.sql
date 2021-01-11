
CREATE PROCEDURE [dbo].[ConsensiLeggePazientiPermessiScrittura]
	@Utente AS varchar(64)

AS
BEGIN

DECLARE @RowCount integer

	SET NOCOUNT ON;

	DECLARE @RESULT bit

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	SET @RESULT = dbo.LeggePazientiPermessiScrittura(@Utente)
	SELECT @RESULT AS PermessoScrittura

	---------------------------------------------------
	-- Completato
	---------------------------------------------------
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	RETURN 1

END;







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiLeggePazientiPermessiScrittura] TO [DataAccessDll]
    AS [dbo];

