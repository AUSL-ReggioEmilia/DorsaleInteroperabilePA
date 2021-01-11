CREATE PROCEDURE [dbo].[BevsRefertiStiliRimuovi]
(
   @Id   uniqueidentifier
)
AS

SET NOCOUNT ON
 
DELETE FROM RefertiStili
   	WHERE [Id] = @Id
 
IF @@ERROR = 0
      RETURN 0
ELSE
      RETURN @@ERROR

SET NOCOUNT OFF

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertiStiliRimuovi] TO [ExecuteFrontEnd]
    AS [dbo];

