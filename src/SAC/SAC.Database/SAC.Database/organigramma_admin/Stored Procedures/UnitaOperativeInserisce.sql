CREATE PROC [organigramma_admin].[UnitaOperativeInserisce]
(
 @UtenteInserimento varchar(128),
 @Codice varchar(16),
 @Descrizione varchar(128),
 @CodiceAzienda varchar(16),
 @Attivo bit
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO [organigramma].[UnitaOperative]
      (
      [Codice],
      [Descrizione],
      [CodiceAzienda],
      [Attivo],
      [DataInserimento],
      [DataModifica],
      [UtenteInserimento],
      [UtenteModifica]
      )
     OUTPUT 
      INSERTED.[ID],
      INSERTED.[Codice],
      INSERTED.[Descrizione],
      INSERTED.[CodiceAzienda],
      INSERTED.[Attivo],
      INSERTED.[DataInserimento],
      INSERTED.[DataModifica],
      INSERTED.[UtenteInserimento],
      INSERTED.[UtenteModifica]
     VALUES
      (
      NULLIF(@Codice, ''),
      NULLIF(@Descrizione, ''),
      NULLIF(@CodiceAzienda, ''),
      @Attivo,
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

    DECLARE @ErrorLogId INT
    EXECUTE dbo.LogError @ErrorLogId OUTPUT;

    EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
    RETURN @ErrorLogId
  END CATCH;
END
