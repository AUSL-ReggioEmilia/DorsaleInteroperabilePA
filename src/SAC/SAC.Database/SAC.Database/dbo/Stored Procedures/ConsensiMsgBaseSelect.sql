
CREATE PROCEDURE [dbo].[ConsensiMsgBaseSelect]
	@Id AS uniqueidentifier
AS
BEGIN

	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT *
	FROM ConsensiMsgBaseResult
	WHERE Id = @Id
		AND Disattivato = 0

END;






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiMsgBaseSelect] TO [DataAccessDll]
    AS [dbo];

