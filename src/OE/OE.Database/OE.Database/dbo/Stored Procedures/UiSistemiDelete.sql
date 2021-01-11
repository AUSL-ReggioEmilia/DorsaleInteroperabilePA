
CREATE PROCEDURE [dbo].[UiSistemiDelete]
 @ID as uniqueidentifier
AS
BEGIN
SET NOCOUNT ON

	IF @ID = '00000000-0000-0000-0000-000000000000'
		RAISERROR  ('Il sistema OE non è cancellabile!', 16, 1)

	RAISERROR  ('Per aggiunggere un Sistema andare sul SAC!', 16, 1)

	--UPDATE [dbo].Sistemi
	--   SET Attivo = 0
	--WHERE [ID] = @ID
		   
	--SELECT * FROM Sistemi WHERE [ID] = @ID
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSistemiDelete] TO [DataAccessUi]
    AS [dbo];

