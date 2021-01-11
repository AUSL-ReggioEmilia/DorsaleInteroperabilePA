CREATE FUNCTION [dbo].[LeggePazientiLivelloAttendibilita]
	( 
	@Utente VARCHAR(64) = NULL
	)
RETURNS TINYINT
AS
BEGIN
	DECLARE @Ret AS TINYINT
	
	IF @Utente IS NULL
		SELECT @Ret=LivelloAttendibilita FROM PazientiUtenti WHERE Utente=USER_NAME()
	ELSE
		SELECT @Ret=LivelloAttendibilita FROM PazientiUtenti WHERE Utente=@Utente
	
	RETURN ISNULL(@Ret, 0)
END

