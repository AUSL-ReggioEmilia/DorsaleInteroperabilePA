
CREATE PROC [organigramma_admin].[RuoliSistemiRimuove]
(
 @ID uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM [organigramma].[RuoliSistemi]
     OUTPUT 
      DELETED.[ID],
      DELETED.[IdRuolo],
      DELETED.[IdSistema],
      DELETED.[DataInserimento],
      DELETED.[DataModifica],
      DELETED.[UtenteInserimento],
      DELETED.[UtenteModifica]
    WHERE [ID] = @ID

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

