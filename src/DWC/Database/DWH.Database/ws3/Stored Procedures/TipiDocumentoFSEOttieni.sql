
-- =============================================
-- Author:		Ettore
-- Create date: 2017-05-11
-- Description:	Restituisce la descrizione dei tipi di documenti
-- Modify date:	2020-11-30 - LeoR: cambiato lo schema da frontend a ws3 per migrazione FSE su Dwh-ws
-- =============================================
CREATE PROCEDURE [ws3].[TipiDocumentoFSEOttieni]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		Codice, Descrizione 
	FROM 
		dbo.TipiDocumentoFSE
END