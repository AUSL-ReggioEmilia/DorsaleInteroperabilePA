
-- =============================================
-- Author:		SimoneB
-- Create date: 2018-02-01
-- Description: Ottiene la lista dei regimi
-- =============================================

CREATE PROC [organigramma_admin].[RegimiCerca]
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF


	SELECT [Codice]
			,[Descrizione]
			,[Ordine]
	FROM [organigramma].[Regimi]
	ORDER BY Ordine
	
END