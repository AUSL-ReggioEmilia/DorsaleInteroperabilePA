-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-26
-- Modify date: 2018-10-16 - Lunghezza utente e desc
-- Description:	Controlla se l'utente ha accesso al OE , utente o gruppo
-- =============================================
CREATE PROCEDURE [dbo].[CoreUtentiVerifyAccess]
	@Utente varchar(256)
AS
BEGIN
	SET NOCOUNT ON;

	------------------------------
	-- SELECT
	------------------------------	
	SELECT uoe.[ID]
			,uoe.[Utente]
			,uoe.[Descrizione]
			,CASE WHEN uoe.Tipo = 1 THEN 'Gruppo' ELSE 'Utente' END AS Tipo 
			,uoe.[Delega]
		FROM [dbo].[Utenti] uoe
		WHERE uoe.[Attivo] = 1
		AND ( uoe.[Utente] = @Utente
			OR EXISTS (
					SELECT *
					FROM [SacOrganigramma].[GruppiUtenti] gu
					WHERE gu.Utente = @Utente
						AND gu.Gruppo = uoe.[Utente]
						AND uoe.Tipo = 1
					)
				)
	ORDER BY uoe.Tipo ASC
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUtentiVerifyAccess] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUtentiVerifyAccess] TO [DataAccessWs]
    AS [dbo];

