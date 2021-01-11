
-- =============================================
-- Author:      Stefano P.
-- Create date: 2016-09-09
-- Description: Ottiene un record da [dbo].[TipiReferto]
-- Modify date: 2017-07-10 - SimoneB: Ottengo anche l'AziendaErogante
-- =============================================
CREATE PROCEDURE [dbo].[BevsTipiRefertoOttieni]
(
  @Id UNIQUEIDENTIFIER
)
AS
BEGIN
  SET NOCOUNT ON  

	SELECT 
	   [Id]
      ,[SistemaErogante]
      ,[SpecialitaErogante]
      ,[Descrizione]
      ,[Icona]
      ,[Ordinamento]
	  ,[AziendaErogante]
	FROM 
		[dbo].[TipiReferto]

	WHERE 
		Id = @Id	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTipiRefertoOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

