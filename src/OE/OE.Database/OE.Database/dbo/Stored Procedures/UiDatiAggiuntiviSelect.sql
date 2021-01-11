


-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-02-13
-- Modify date: 
-- Description: Ottiene un record dati aggiuntivi
-- =============================================
CREATE PROC [dbo].[UiDatiAggiuntiviSelect]
(
 @Nome varchar(128)
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      [Nome],     
      [Descrizione],
      [Visibile]
  FROM  [DatiAggiuntivi]
  WHERE [Nome] = @Nome

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAggiuntiviSelect] TO [DataAccessUi]
    AS [dbo];

