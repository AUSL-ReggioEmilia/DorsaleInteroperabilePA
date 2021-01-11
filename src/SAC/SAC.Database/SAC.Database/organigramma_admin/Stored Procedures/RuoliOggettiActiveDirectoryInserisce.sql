CREATE PROC [organigramma_admin].[RuoliOggettiActiveDirectoryInserisce]
(
 @IdRuolo uniqueidentifier,
 @IdUtente uniqueidentifier,
 @UtenteInserimento varchar(128)
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

	INSERT INTO [organigramma].[RuoliOggettiActiveDirectory]
	   (
	    [IdRuolo]
	   ,[IdUtente]
	   ,[DataInserimento]
	   ,[DataModifica]
	   ,[UtenteInserimento]
	   ,[UtenteModifica]
	   )
    OUTPUT 
        INSERTED.[IdRuolo]
       ,INSERTED.[IdUtente]
       ,INSERTED.[DataInserimento]
       ,INSERTED.[DataModifica]
       ,INSERTED.[UtenteInserimento]
       ,INSERTED.[UtenteModifica]
    VALUES
		(
		@IdRuolo,
		@IdUtente,
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
