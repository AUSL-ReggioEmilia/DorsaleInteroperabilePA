


CREATE PROCEDURE [dbo].[UiEnnupleDelete]

 @ID as uniqueidentifier

AS
BEGIN
SET NOCOUNT ON

DELETE from [dbo].[Ennuple]  WHERE ID = @ID

SET NOCOUNT OFF
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleDelete] TO [DataAccessUi]
    AS [dbo];

