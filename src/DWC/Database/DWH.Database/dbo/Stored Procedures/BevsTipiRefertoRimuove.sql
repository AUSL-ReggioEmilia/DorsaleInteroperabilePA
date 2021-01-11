-- =============================================
-- Author:      Stefano P.
-- Create date: 2016-09-13
-- Description: Elimina una riga di dbo.TipiReferto
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[BevsTipiRefertoRimuove]
(	
	@ID UNIQUEIDENTIFIER
)
AS
BEGIN
		
	DELETE [dbo].[TipiReferto]
    WHERE ID=@ID
   
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsTipiRefertoRimuove] TO [ExecuteFrontEnd]
    AS [dbo];

