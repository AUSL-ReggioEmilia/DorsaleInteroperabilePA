

CREATE PROC [organigramma_admin].[RuoliUnitaOperativeInserisce]
(
 @UtenteInserimento varchar(128),
 @IdRuolo uniqueidentifier,
 @IdUnitaOperativa uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO organigramma.RuoliUnitaOperative
      (
      IdRuolo,
      IdUnitaOperativa,
      DataInserimento,
      DataModifica,
      UtenteInserimento,
      UtenteModifica
      )
     OUTPUT 
      INSERTED.ID,
      INSERTED.IdRuolo,
      INSERTED.IdUnitaOperativa,
      INSERTED.DataInserimento,
      INSERTED.DataModifica,
      INSERTED.UtenteInserimento,
      INSERTED.UtenteModifica
     VALUES
      (
      @IdRuolo,
      @IdUnitaOperativa,
      GETUTCDATE(),
      GETUTCDATE(),
      NULLIF(@UtenteInserimento, ''),
      NULLIF(@UtenteInserimento, '')
      )

    COMMIT TRANSACTION;

    RETURN 0

  END TRY
  BEGIN CATCH
	--print 'errore: ' + cast(ERROR_NUMBER() as varchar)
	
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
