
-- =============================================
-- Author:		
-- Modify date: 2018-10-16 - refactoty e lunghezza utente e desc
-- Description:	Controlla se l'utente ha accesso al OE , utente o gruppo
-- =============================================
CREATE PROCEDURE [dbo].[UiUtentiUpdate]
(
 @ID as uniqueidentifier
,@Attivo as bit
,@Delega as tinyint
)
AS
BEGIN

	SET NOCOUNT ON

	UPDATE [dbo].[Utenti]
	   SET [Attivo] = @Attivo
		  ,[Delega] = @Delega
	 WHERE [ID] = @ID

	SELECT *
	FROM [UTENTI]
	 WHERE [ID] = @ID

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUtentiUpdate] TO [DataAccessUi]
    AS [dbo];

