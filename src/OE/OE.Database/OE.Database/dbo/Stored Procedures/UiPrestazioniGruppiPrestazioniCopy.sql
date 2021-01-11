-- =============================================
-- Author: Stefano Piletti     
-- Create date: 2015-07-17
-- Description: Copia delle prestazioni da un Gruppo di prestazioni ad un altro
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[UiPrestazioniGruppiPrestazioniCopy]
	@IDGruppoOrigine UNIQUEIDENTIFIER,
	@IDGruppoDestinazione UNIQUEIDENTIFIER
AS
BEGIN

	INSERT INTO [dbo].PrestazioniGruppiPrestazioni
           (ID
           ,IDPrestazione
           ,IDGruppoPrestazioni)
    SELECT
           NEWID()
           ,P2.IDPrestazione
           ,@IDGruppoDestinazione
    FROM [dbo].PrestazioniGruppiPrestazioni P2
    WHERE 
		P2.IDGruppoPrestazioni = @IDGruppoOrigine
		AND EXISTS (SELECT 1 FROM GruppiPrestazioni WHERE ID=@IDGruppoOrigine)
		AND EXISTS (SELECT 1 FROM GruppiPrestazioni WHERE ID=@IDGruppoDestinazione)
       
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniGruppiPrestazioniCopy] TO [DataAccessUi]
    AS [dbo];

