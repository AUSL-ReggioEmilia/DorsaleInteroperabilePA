CREATE FUNCTION [dbo].[LeggeConsensiProvenienza]
	( 
	@Utente VARCHAR(64) = NULL
	)
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(64)
	
	IF @Utente IS NULL
		SELECT @Ret=Provenienza FROM ConsensiUtenti WHERE Utente=USER_NAME()
	ELSE
		SELECT @Ret=Provenienza FROM ConsensiUtenti WHERE Utente=@Utente
	
	RETURN NULLIF(@Ret, '')
END


