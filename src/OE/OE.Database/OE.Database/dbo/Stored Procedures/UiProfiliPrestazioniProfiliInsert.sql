
CREATE PROCEDURE [dbo].[UiProfiliPrestazioniProfiliInsert]
	@IdPrestazione as uniqueidentifier,
	@IdProfilo as uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON

	IF dbo.IsProfiloNelProfiloRecursivo(@IdPrestazione, @IdProfilo) > 0
		BEGIN
			RAISERROR ('Il profilo è gia presente nella catena', 16, 1)
 			RETURN 0
		END
	ELSE
		BEGIN
			DECLARE @newId as uniqueidentifier = NEWID()

			INSERT INTO [dbo].PrestazioniProfili
					   ([ID]
					   ,IDFiglio
					   ,IDPadre)
				 VALUES
					   (@newId
					   ,@IdPrestazione
					   ,@IdProfilo)

			SELECT * FROM PrestazioniProfili WHERE ID = @newId
			RETURN 0
		END
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiProfiliPrestazioniProfiliInsert] TO [DataAccessUi]
    AS [dbo];

