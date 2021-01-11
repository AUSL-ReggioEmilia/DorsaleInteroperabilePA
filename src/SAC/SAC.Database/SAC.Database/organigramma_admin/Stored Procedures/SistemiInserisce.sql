CREATE PROC [organigramma_admin].[SistemiInserisce]
(
 @UtenteInserimento varchar(128),
 @Codice varchar(16),
 @CodiceAzienda varchar(16),
 @Descrizione varchar(128),
 @Erogante bit,
 @Richiedente bit,
 @Attivo bit
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO [organigramma].[Sistemi]
      (
      [Codice],
      [CodiceAzienda],
      [Descrizione],
      [Erogante],
      [Richiedente],
      [Attivo],     
      [DataInserimento],
      [DataModifica],
      [UtenteInserimento],
      [UtenteModifica]
      )
     OUTPUT 
      INSERTED.[ID],
      INSERTED.[Codice],
      INSERTED.[CodiceAzienda],
      INSERTED.[Descrizione],
      INSERTED.[Erogante],
      INSERTED.[Richiedente],
      INSERTED.[Attivo],
      INSERTED.[DataInserimento],
      INSERTED.[DataModifica],
      INSERTED.[UtenteInserimento],
      INSERTED.[UtenteModifica]
     VALUES
      (
      NULLIF(@Codice, ''),
      NULLIF(@CodiceAzienda, ''),
      NULLIF(@Descrizione, ''),
      @Erogante,
      @Richiedente,
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
