

CREATE PROC [organigramma_admin].[UnitaOperativeModifica]
(
 @ID uniqueidentifier,
 @UtenteModifica varchar(128),
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

    UPDATE [organigramma].[UnitaOperative]
     SET
      [Codice] = NULLIF(@Codice, ''),
      [Descrizione] = NULLIF(@Descrizione, ''),
      [CodiceAzienda] = NULLIF(@CodiceAzienda, ''),
      [Attivo] = @Attivo,
      [DataModifica] = GETUTCDATE(),
      [UtenteModifica] = NULLIF(@UtenteModifica, '')
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
