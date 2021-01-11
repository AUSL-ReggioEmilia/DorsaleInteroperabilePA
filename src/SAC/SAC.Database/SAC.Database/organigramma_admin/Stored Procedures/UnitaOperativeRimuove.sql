

CREATE PROC [organigramma_admin].[UnitaOperativeRimuove]
(
 @ID uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM [organigramma].[UnitaOperative]
     OUTPUT 
      DELETED.[ID],
      DELETED.[Codice],
      DELETED.[Descrizione],
      DELETED.[CodiceAzienda],
      DELETED.[Attivo],
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
