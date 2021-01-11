


CREATE PROCEDURE [dbo].[UiEnnupleAccessiDelete]

 @ID as uniqueidentifier

AS
BEGIN
SET NOCOUNT ON

DELETE from [dbo].[EnnupleAccessi]  WHERE ID = @ID

SET NOCOUNT OFF
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleAccessiDelete] TO [DataAccessUi]
    AS [dbo];

