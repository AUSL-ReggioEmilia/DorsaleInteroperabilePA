
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-07-24
-- Description: Ricerca Principi Attivi con filtri opzionali
-- Modify date: 2015-11-26 Stefano P: Aggiunto % ricerca su Descrizione
-- =============================================
CREATE PROC [codifiche_admin].[FarmaPrincipiAttiviCerca]
( 
 @Codice int = NULL,
 @Descrizione varchar(200) = NULL,
 @ATCCorrelati varchar(70) = NULL,
 @PABase varchar(6) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SELECT TOP (ISNULL(@Top, 200)) 
      [Id],     
      [Codice],
      [Descrizione],
      [ATCCorrelati],
      [Veterinario],
      [ScadenzaBrevetto],
      [PABase]
   
  FROM  
	  [codifiche].[FarmaPrincipiAttivi]
  WHERE 
      (Codice = @Codice OR @Codice IS NULL) AND 
      (Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) AND 
      (ATCCorrelati LIKE '%' + @ATCCorrelati + '%' OR @ATCCorrelati IS NULL) AND 
      (PABase LIKE @PABase + '%' OR @PABase IS NULL)
  
  ORDER BY 
	Descrizione

END
