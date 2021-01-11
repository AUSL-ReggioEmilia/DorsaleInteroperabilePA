
CREATE PROC [organigramma_admin].[PermessiUtentiModifica]
(
 @Id uniqueidentifier,
 @Lettura bit,
 @Scrittura bit,
 @Cancellazione bit,
 @Disattivato tinyint
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE [organigramma].[PermessiUtenti]
     SET    
      [Lettura] = @Lettura,
      [Scrittura] = @Scrittura,
      [Cancellazione] = @Cancellazione,
      [Disattivato] = @Disattivato
     OUTPUT 
      INSERTED.[Id],
      INSERTED.[Utente],
      INSERTED.[Lettura],
      INSERTED.[Scrittura],
      INSERTED.[Cancellazione],
      INSERTED.[Disattivato]
    WHERE [Id] = @Id

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

GO


