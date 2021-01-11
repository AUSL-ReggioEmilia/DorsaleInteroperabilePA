CREATE FUNCTION [dbo].[LeggeConsensiPermessiCancellazione]
	( 
	@Utente VARCHAR(64) = NULL
	)
RETURNS BIT
AS
BEGIN
	DECLARE @Ret AS BIT
	
	IF @Utente IS NULL
		SELECT @Ret=Cancellazione FROM ConsensiUtenti INNER JOIN Utenti
						ON ConsensiUtenti.Utente = Utenti.Utente
			WHERE 
					ConsensiUtenti.Utente=USER_NAME()
				AND Utenti.Disattivato = 0
				AND ConsensiUtenti.Disattivato = 0
	ELSE
		SELECT @Ret=Cancellazione FROM ConsensiUtenti INNER JOIN Utenti
						ON ConsensiUtenti.Utente = Utenti.Utente
			WHERE 
					ConsensiUtenti.Utente=@Utente
				AND Utenti.Disattivato = 0
				AND ConsensiUtenti.Disattivato = 0
	
	RETURN ISNULL(@Ret, 0)
END

