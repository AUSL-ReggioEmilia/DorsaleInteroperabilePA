

-- =============================================
-- Author:      Stefano P.
-- Create date: 2016-09-09
-- Description: Ricerca su [dbo].[TipiReferto]
-- Modify date: 2017-07-10 - SimoneB: Ottengo anche l'azienda erogante.
-- Modify Date: 2109-05-29 - SImoneB: Restituisco anche l'icona
-- =============================================
CREATE PROCEDURE [dbo].[BevsTipiRefertoCerca]
(
  @SistemaErogante VARCHAR(16) = NULL
  ,@AziendaErogante VARCHAR(16) = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT ON  

	SELECT 
	   [Id]
      ,[SistemaErogante]
      ,[SpecialitaErogante]
      ,[Descrizione]
	  --,CAST(NULL AS VARBINARY(MAX)) AS Icona
	  ,Icona
      ,[Ordinamento]
	  ,[AziendaErogante]
	FROM 
		[dbo].[TipiReferto]

	WHERE		
		(@SistemaErogante IS NULL OR SistemaErogante = @SistemaErogante)
		AND (@AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante)

	ORDER BY 
		Ordinamento	
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTipiRefertoCerca] TO [ExecuteFrontEnd]
    AS [dbo];

