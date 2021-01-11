
-- =============================================
-- Author:		Bellini
-- Create date: 2014-09-26
-- Modify date: 2018-10-16 - refactoty e lunghezza utente e desc
-- Description:	Controlla se l'utente ha accesso al OE , utente o gruppo
-- =============================================
CREATE PROCEDURE [dbo].[UiUtentiInsert]
(
 @Utente as varchar(256)
,@Descrizione as varchar(1024)
,@Delega as tinyint
,@Attivo as bit
,@Tipo as tinyint = 0  -- 0:utente   1:gruppo
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @NEWID AS UNIQUEIDENTIFIER = NEWID()

	INSERT INTO dbo.Utenti
           (ID
           ,Utente
           ,Descrizione
           ,Attivo
           ,Delega
           ,Tipo)
     VALUES
           (@NEWID
           ,@Utente
           ,@Descrizione
           ,@Attivo
           ,@Delega
           ,@Tipo)

	SELECT *
	FROM Utenti
	WHERE ID = @NEWID

END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUtentiInsert] TO [DataAccessUi]
    AS [dbo];

