-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-02-13
-- Modify date: 
-- Description: Ricerca dati aggiuntivi
-- =============================================
CREATE PROC [dbo].[UiDatiAggiuntiviList]
(
 @Nome varchar(128) = NULL,
 @Descrizione varchar(256) = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      [Nome],
      [Descrizione],
      [Visibile]
  FROM  [dbo].[DatiAggiuntivi]
  WHERE 
      (Nome LIKE @Nome + '%' OR @Nome IS NULL) 
      AND 
      (Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL)

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAggiuntiviList] TO [DataAccessUi]
    AS [dbo];

