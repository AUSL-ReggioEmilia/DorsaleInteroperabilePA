


CREATE PROCEDURE [dbo].[UiUnitaOperativeDelete]

 @ID as uniqueidentifier

AS
BEGIN
SET NOCOUNT ON

	RAISERROR  ('Per cancellare una Unita Operativa andare sul SAC!', 16, 1)


--UPDATE [dbo].UnitaOperative
--   SET Attivo = 0
-- WHERE [ID] = @ID
	   
--select * from UnitaOperative WHERE [ID] = @ID

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUnitaOperativeDelete] TO [DataAccessUi]
    AS [dbo];

