-- =============================================
-- Author: Stefano Piletti     
-- Create date: 2015-07-20
-- Description: Copia delle prestazioni da un Profilo di prestazioni ad un altro
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[UiPrestazioniProfiloPrestazioniCopy]
	@IDProfiloOrigine UNIQUEIDENTIFIER,
	@IDProfiloDestinazione UNIQUEIDENTIFIER
AS
BEGIN

	INSERT INTO [dbo].PrestazioniProfili
           (ID
           ,IDFiglio
           ,IDPadre)
    SELECT
           NEWID()
           ,P2.IDFiglio
           ,@IDProfiloDestinazione
    FROM [dbo].PrestazioniProfili P2
    WHERE 
		P2.IDPadre = @IDProfiloOrigine
		AND EXISTS (SELECT 1 FROM dbo.Prestazioni WHERE ID=@IDProfiloOrigine)
		AND EXISTS (SELECT 1 FROM dbo.Prestazioni WHERE ID=@IDProfiloDestinazione)
       
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniProfiloPrestazioniCopy] TO [DataAccessUi]
    AS [dbo];

