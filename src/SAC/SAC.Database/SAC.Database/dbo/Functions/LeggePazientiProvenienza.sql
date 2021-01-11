CREATE FUNCTION [dbo].[LeggePazientiProvenienza]
	( 
	@Utente VARCHAR(64) = NULL
	)
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(64)
	
	IF @Utente IS NULL
		SELECT @Ret=Provenienza FROM PazientiUtenti WHERE Utente=USER_NAME()
	ELSE
		SELECT @Ret=Provenienza FROM PazientiUtenti WHERE Utente=@Utente
	
	RETURN NULLIF(@Ret, '')
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LeggePazientiProvenienza] TO PUBLIC
    AS [dbo];

