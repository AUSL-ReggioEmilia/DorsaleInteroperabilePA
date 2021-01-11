
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-02-13
-- Modify date: 
-- Description: Aggiorna un record dati aggiuntivi
-- =============================================
CREATE PROC [dbo].[UiDatiAggiuntiviUpdate]
(
 @Nome varchar(128),
 @Descrizione varchar(256),
 @Visibile bit
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE [dbo].[DatiAggiuntivi]
     SET
      [DataModifica] = GETUTCDATE(),
      [UtenteModifica] = SUSER_NAME(),
      [Descrizione] = NULLIF(@Descrizione, ''),
      [Visibile] = @Visibile
     OUTPUT 
      INSERTED.[Nome],      
      INSERTED.[Descrizione],
      INSERTED.[Visibile]
    WHERE [Nome] = @Nome

    COMMIT TRANSACTION;

    RETURN 0

  END TRY
  BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN
      ROLLBACK TRANSACTION;
    END

    DECLARE @ErrorMessage varchar(2560)
	SELECT @ErrorMessage = dbo.GetException()		
	RAISERROR(@ErrorMessage, 16, 1)
	
  END CATCH;
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAggiuntiviUpdate] TO [DataAccessUi]
    AS [dbo];

