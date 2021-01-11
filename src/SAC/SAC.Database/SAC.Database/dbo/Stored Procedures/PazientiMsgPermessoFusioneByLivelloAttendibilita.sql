


CREATE PROCEDURE [dbo].[PazientiMsgPermessoFusioneByLivelloAttendibilita]
	@LivelloAttendibilita tinyint
AS
BEGIN

	SELECT CAST(dbo.GetPermessoFusioneByLivelloAttendibilita(@LivelloAttendibilita) as bit) AS PermessoFusione 

END
















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgPermessoFusioneByLivelloAttendibilita] TO [DataAccessDll]
    AS [dbo];

