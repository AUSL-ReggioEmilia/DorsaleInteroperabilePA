
-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2018-01-25
-- Description:	Restituisce la lista codice-descrizione delle aziende per la lista dei documenti FSE
-- Modify date:	2020-11-30 - LeoR: cambiato lo schema da frontend a ws3 per migrazione FSE su Dwh-ws
-- =============================================
CREATE PROCEDURE [ws3].[DizionarioAziendeFSE]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		Codice
		, Descrizione
	FROM 
		dbo.DizionarioAziendeFSE
END