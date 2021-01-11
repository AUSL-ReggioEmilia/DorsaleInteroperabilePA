
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-06-16
-- Description: Eliminazione Utenti
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[BevsUtentiRimuovi]
(
	@Id UNIQUEIDENTIFIER
)
AS

	DELETE dbo.Utenti
	WHERE Id = @Id


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsUtentiRimuovi] TO [ExecuteFrontEnd]
    AS [dbo];

