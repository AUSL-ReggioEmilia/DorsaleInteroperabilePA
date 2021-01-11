

-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-12-21
-- Description:	Lista di Comuni per regione
-- =============================================
CREATE PROCEDURE [pazienti_ws].[IstatComuniByRegione]
(
	  @Nome varchar(128)
	, @Obsoleti bit
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		  IstatComuni.Codice
		, IstatComuni.Nome
		, IstatComuni.CodiceProvincia
		, CASE 
			WHEN GETDATE() BETWEEN ISNULL(IstatComuni.DataInizioValidita, '1800-01-01') AND ISNULL(IstatComuni.DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
			END AS Obsoleto
		, IstatComuni.DataFineValidita AS ObsoletoData		

	FROM 
		dbo.IstatComuni
		INNER JOIN dbo.IstatProvince ON IstatComuni.CodiceProvincia = IstatProvince.Codice
		INNER JOIN dbo.IstatRegioni ON IstatProvince.CodiceRegione = IstatRegioni.Codice
	
	WHERE
			(IstatRegioni.Nome LIKE @Nome OR @Nome IS NULL)
		AND (IstatComuni.Nazione = 0)
		AND 
		(
			(@Obsoleti IS NULL) OR 
			 (CASE 
				WHEN GETDATE() BETWEEN ISNULL(IstatComuni.DataInizioValidita, '1800-01-01') AND ISNULL(IstatComuni.DataFineValidita, GETDATE()) THEN
					CAST(0 AS BIT) 
				ELSE CAST(1 AS BIT) 
				END = @Obsoleti) 
		)
		AND (IstatComuni.Nome NOT LIKE '%{Codice Sconosciuto}%')
	
END