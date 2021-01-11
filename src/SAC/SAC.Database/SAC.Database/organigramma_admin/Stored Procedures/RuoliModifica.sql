
-- =============================================
-- Author:		/
-- Create date: /
-- Description:	Modifica un ruolo
-- Modify date: 2018-01-19 SimoneB: Aggiunto parametro @Note
-- =============================================
CREATE PROC [organigramma_admin].[RuoliModifica]
(
 @ID uniqueidentifier,
 @UtenteModifica varchar(128),
 @Codice varchar(16),
 @Descrizione varchar(128),
 @Attivo bit,
 @Note VARCHAR(1024)
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE [organigramma].[Ruoli]
     SET
      [Codice] = NULLIF(@Codice, ''),
      [Descrizione] = NULLIF(@Descrizione, ''),
      [Attivo] = @Attivo,
      [DataModifica] = GETUTCDATE(),
      [UtenteModifica] = NULLIF(@UtenteModifica, ''),
	  [Note] = NULLIF(@Note, '')
     OUTPUT 
      INSERTED.[ID],
      INSERTED.[Codice],
      INSERTED.[Descrizione],
      INSERTED.[Attivo],
      INSERTED.[DataInserimento],
      INSERTED.[DataModifica],
      INSERTED.[UtenteInserimento],
      INSERTED.[UtenteModifica],
	  INSERTED.[Note]
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
