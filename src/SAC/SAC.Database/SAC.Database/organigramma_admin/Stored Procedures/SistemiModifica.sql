
CREATE PROC [organigramma_admin].[SistemiModifica]
(
 @ID uniqueidentifier,
 @UtenteModifica varchar(128),
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

    UPDATE [organigramma].[Sistemi]
     SET
      [Codice] = NULLIF(@Codice, ''),
      [CodiceAzienda] = NULLIF(@CodiceAzienda, ''),
      [Descrizione] = NULLIF(@Descrizione, ''),
      [Erogante] = @Erogante,
      [Richiedente] = @Richiedente,
      [Attivo] = @Attivo,
      [DataModifica] = GETUTCDATE(),
      [UtenteModifica] = NULLIF(@UtenteModifica, '')
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
