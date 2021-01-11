CREATE PROC [organigramma_admin].[PermessiUtentiInserisce]
(
 @Utente varchar(64),
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

    INSERT INTO [organigramma].[PermessiUtenti]
      (
      [Utente],
      [Lettura],
      [Scrittura],
      [Cancellazione],
      [Disattivato]
      )
     OUTPUT 
      INSERTED.[Id],
      INSERTED.[Utente],
      INSERTED.[Lettura],
      INSERTED.[Scrittura],
      INSERTED.[Cancellazione],
      INSERTED.[Disattivato]
     VALUES
      (
      @Utente,
      @Lettura,
      @Scrittura,
      @Cancellazione,
      @Disattivato
      )

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


