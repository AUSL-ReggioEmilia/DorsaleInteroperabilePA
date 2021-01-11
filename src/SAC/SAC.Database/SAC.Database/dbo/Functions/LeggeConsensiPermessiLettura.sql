CREATE FUNCTION [dbo].[LeggeConsensiPermessiLettura]
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
			-- Controlla accessi applicativi
			
			SELECT @Ret=Lettura
			FROM ConsensiUtenti INNER JOIN Utenti
						ON ConsensiUtenti.Utente = Utenti.Utente
			WHERE	ConsensiUtenti.Utente=@Utente
				AND Utenti.Disattivato = 0
				AND ConsensiUtenti.Disattivato = 0
		END
	
	RETURN ISNULL(@Ret, 0)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[LeggeConsensiPermessiLettura] TO PUBLIC
    AS [dbo];

