CREATE PROC [organigramma_admin].[RuoliSistemiInserisce]
(
 @UtenteInserimento varchar(128),
 @IdRuolo uniqueidentifier,
 @IdSistema uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO [organigramma].[RuoliSistemi]
      (
      [IdRuolo],
      [IdSistema],
      [DataInserimento],
      [DataModifica],
      [UtenteInserimento],
      [UtenteModifica]
      )
     OUTPUT 
      INSERTED.[ID],
      INSERTED.[IdRuolo],
      INSERTED.[IdSistema],
      INSERTED.[DataInserimento],
      INSERTED.[DataModifica],
      INSERTED.[UtenteInserimento],
      INSERTED.[UtenteModifica]
     VALUES
      (
      @IdRuolo,
      @IdSistema,
      GETUTCDATE(),
      GETUTCDATE(),
      NULLIF(@UtenteInserimento, ''),
      NULLIF(@UtenteInserimento, '')
      )

    COMMIT TRANSACTION;

    RETURN 0

  END TRY
  BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN
      ROLLBACK TRANSACTION;
    END

	--NASCONDO L'ERRORE IN INSERIMENTO DI CHIAVE DUPLICATA PERCHE' NON OCCORRE MOSTRARLO AL CHIAMANTE
	IF ERROR_NUMBER() = 2601 RETURN 0

    DECLARE @ErrorLogId INT
    EXECUTE dbo.LogError @ErrorLogId OUTPUT;

    EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
    RETURN @ErrorLogId
  END CATCH;
END
