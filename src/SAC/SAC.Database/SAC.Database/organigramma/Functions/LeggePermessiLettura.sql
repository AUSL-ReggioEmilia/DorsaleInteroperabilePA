
CREATE FUNCTION [organigramma].[LeggePermessiLettura]
( 
@Utente VARCHAR(64) = NULL
)
RETURNS BIT
AS
BEGIN
	DECLARE @Ret AS BIT
	
	IF @Utente IS NULL
		BEGIN
		-- Non controllo IS_MEMBER perche se accedo alle viste ho già
		--	 i diritti di 'DataAccessSql'
		SET @Ret = 1

		END
	ELSE
		BEGIN
		--
		-- Controlla accessi applicativi
		SELECT @Ret = Lettura
		FROM [organigramma].[PermessiUtenti] Permessi
			INNER JOIN Utenti ON Permessi.Utente = Utenti.Utente
		WHERE Permessi.Utente = ISNULL(@Utente, SUSER_NAME())
			AND Utenti.Disattivato = 0
			AND Permessi.Disattivato = 0
		
		END
		
	RETURN ISNULL(@Ret, 0)
END
