
CREATE PROCEDURE [dbo].[UtentiUiSQLServerLista]
	@Utente VARCHAR(64) = NULL,
	@Type VARCHAR(1) = NULL
WITH EXECUTE AS OWNER -- RICHIESTO PER CONSENTIRE LA LETTURA DELLA SYS.DATABASE_PRINCIPALS
AS

BEGIN
	SET NOCOUNT ON;

	SELECT 
		Name, 
		CASE [type]
			WHEN 'S' THEN 'Utente SQL'
			WHEN 'U' THEN 'Utente di Windows'
			WHEN 'G' THEN 'Gruppo di Windows'
			WHEN 'A' THEN 'Ruolo applicazione'
			WHEN 'R' THEN 'Ruolo del database'
			WHEN 'C' THEN 'Utente sul quale è stato eseguito il mapping a un certificato'
			WHEN 'K' THEN 'Utente sul quale è stato eseguito il mapping a una chiave asimmetrica'
		END AS Type_Desc
	
	FROM SYS.DATABASE_PRINCIPALS
	
	WHERE		
		(@Utente IS NULL OR Name LIKE '%'+ @Utente +'%')
		AND (@Type IS NULL OR [type] = @Type)
	
	ORDER BY Name 

END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiUiSQLServerLista] TO [DataAccessUi]
    AS [dbo];

