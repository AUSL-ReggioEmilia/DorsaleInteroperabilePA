

-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-02-13
-- Modify date: 
-- Description: Rimuove un record dati aggiuntivi
-- =============================================
CREATE PROC [dbo].[UiDatiAggiuntiviDelete]
(
 @Nome varchar(128)
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM [dbo].[DatiAggiuntivi]
     OUTPUT 
      DELETED.[Nome],    
      DELETED.[Descrizione],
      DELETED.[Visibile]
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
    ON OBJECT::[dbo].[UiDatiAggiuntiviDelete] TO [DataAccessUi]
    AS [dbo];

