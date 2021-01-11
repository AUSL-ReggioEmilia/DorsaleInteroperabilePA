


CREATE PROCEDURE [dbo].[PazientiMsgPermessoFusioneByProvenienza]
	@Provenienza varchar(16)

AS
BEGIN

	SELECT dbo.GetPermessoFusioneByProvenienza(@Provenienza) AS PermessoFusione

END
















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgPermessoFusioneByProvenienza] TO [DataAccessDll]
    AS [dbo];

