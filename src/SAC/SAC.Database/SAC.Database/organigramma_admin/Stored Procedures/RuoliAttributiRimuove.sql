
CREATE PROC [organigramma_admin].[RuoliAttributiRimuove]
(
 @ID uniqueidentifier,
 @TipoAttributo tinyint --0: att. di ruolo    1: att. di sistema   2: att. di unità operativa
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

	IF @TipoAttributo = 0 BEGIN
		
		DELETE FROM [organigramma].[RuoliAttributi]
		WHERE [ID] = @ID
	
	END 
	ELSE IF @TipoAttributo = 1 BEGIN
		
		DELETE FROM [organigramma].[RuoliSistemiAttributi]
		WHERE [ID] = @ID
	
	END 
	ELSE IF @TipoAttributo = 2 BEGIN
		
		DELETE FROM [organigramma].[RuoliUnitaOperativeAttributi]
		WHERE [ID] = @ID
	
	END 
	
	
    COMMIT TRANSACTION;
    RETURN 0

  END TRY
  BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN
      ROLLBACK TRANSACTION;
    END

    DECLARE @ErrorLogId INT
    EXECUTE dbo.LogError @ErrorLogId OUTPUT;

    EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
    RETURN @ErrorLogId
  END CATCH;
END

