
CREATE FUNCTION [organigramma].[LeggePermessiCancellazione]
( 
@Utente VARCHAR(64) = NULL
)
RETURNS BIT
AS
BEGIN
	DECLARE @Ret AS BIT

	SELECT @Ret = Cancellazione
		FROM [organigramma].[PermessiUtenti] Permessi
			INNER JOIN Utenti ON Permessi.Utente = Utenti.Utente
		WHERE Permessi.Utente = ISNULL(@Utente, SUSER_NAME())
			AND Utenti.Disattivato = 0
			AND Permessi.Disattivato = 0
	
	RETURN ISNULL(@Ret, 0)
END
