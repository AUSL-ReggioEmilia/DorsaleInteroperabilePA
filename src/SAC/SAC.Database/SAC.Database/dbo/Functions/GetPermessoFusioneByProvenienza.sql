
CREATE FUNCTION [dbo].[GetPermessoFusioneByProvenienza](
	@Provenienza AS varchar(16)
)
RETURNS bit
AS
BEGIN
--
-- La funzione ritorna True per quelle provenienza per le quali è permesso
-- fondere le posizioni in altre posizioni
-- Per LHA NON è permesso.
--
	DECLARE @Ret AS bit
	SET @Ret = 1

	IF @Provenienza = 'LHA' SET @Ret = 0

	RETURN @Ret
END


