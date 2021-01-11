CREATE FUNCTION [dbo].[LeggePazientiId]
	( 
		@Provenienza VARCHAR(16) = NULL,
		@IdProvenienza varchar(64) = NULL
	)
RETURNS uniqueidentifier
AS
BEGIN
	DECLARE @Ret uniqueidentifier
	
	SELECT @Ret=Id FROM Pazienti 
		WHERE Provenienza = @Provenienza AND IdProvenienza = @IdProvenienza
		ORDER BY DataInserimento DESC
	
	RETURN NULLIF(@Ret, null)
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LeggePazientiId] TO PUBLIC
    AS [dbo];

