
-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-12-21
-- Description:	Lista di Comuni per Nome
-- =============================================
CREATE PROCEDURE [pazienti_ws].[IstatComuniByNome]
(
	  @Nome varchar(128)
	, @Obsoleti bit
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		Codice
		, Nome
		, CodiceProvincia
		, CASE 
			WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
			END AS Obsoleto
		, DataFineValidita AS ObsoletoData		
	FROM 
		dbo.IstatComuni
	WHERE
		(Nome LIKE @Nome OR @Nome IS NULL)
		AND (Nazione = 0)
		AND 
		(
			(@Obsoleti IS NULL) OR 
			 (CASE 
				WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
					CAST(0 AS BIT) 
				ELSE CAST(1 AS BIT) 
				END = @Obsoleti) 
		)
		AND (Nome NOT LIKE '%{Codice Sconosciuto}%')
END