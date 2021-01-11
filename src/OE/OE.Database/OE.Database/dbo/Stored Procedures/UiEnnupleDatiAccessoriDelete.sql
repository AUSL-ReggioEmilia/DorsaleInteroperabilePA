



CREATE PROCEDURE [dbo].[UiEnnupleDatiAccessoriDelete]

 @ID as uniqueidentifier

AS
BEGIN
SET NOCOUNT ON

DELETE from [dbo].[EnnupleDatiAccessori]  WHERE ID = @ID

SET NOCOUNT OFF
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleDatiAccessoriDelete] TO [DataAccessUi]
    AS [dbo];

