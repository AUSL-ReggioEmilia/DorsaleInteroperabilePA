
-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-12-21
-- Description:	Lista di Comuni esteri (nazioni)
-- =============================================
CREATE PROCEDURE [pazienti_ws].[IstatComuniEsteri]
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		Codice
		, Nome
		, CAST(NULL AS VARCHAR(3)) AS CodiceProvincia  
		, CASE 
			WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
			END AS Obsoleto
		, DataFineValidita AS ObsoletoData
	FROM 
		dbo.IstatComuni

	WHERE
			(IstatComuni.Nazione = 1)
		AND (IstatComuni.Nome NOT LIKE '%{Codice Sconosciuto}%')
	
END