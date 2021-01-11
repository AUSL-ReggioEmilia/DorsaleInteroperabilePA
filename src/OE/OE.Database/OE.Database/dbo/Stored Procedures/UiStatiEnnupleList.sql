

CREATE PROCEDURE [dbo].[UiStatiEnnupleList]

AS
BEGIN
SET NOCOUNT ON

SELECT [ID]
      ,[Descrizione]
  FROM [dbo].[EnnupleStati]

SET NOCOUNT OFF
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiStatiEnnupleList] TO [DataAccessUi]
    AS [dbo];

