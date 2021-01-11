CREATE FUNCTION [dbo].[LeggePazientiPermessiScrittura]
	( 
	@Utente VARCHAR(64) = NULL
	)
RETURNS BIT
AS
BEGIN
	DECLARE @Ret AS BIT
	
	IF @Utente IS NULL
		SELECT @Ret=Scrittura FROM PazientiUtenti INNER JOIN Utenti
						ON PazientiUtenti.Utente = Utenti.Utente
			WHERE 
					PazientiUtenti.Utente=USER_NAME()
				AND Utenti.Disattivato = 0
				AND PazientiUtenti.Disattivato = 0
	ELSE
		SELECT @Ret=Scrittura FROM PazientiUtenti INNER JOIN Utenti
						ON PazientiUtenti.Utente = Utenti.Utente
			WHERE 
					PazientiUtenti.Utente=@Utente
				AND Utenti.Disattivato = 0
				AND PazientiUtenti.Disattivato = 0
	
	RETURN ISNULL(@Ret, 0)
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LeggePazientiPermessiScrittura] TO PUBLIC
    AS [dbo];

