-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-12-21
-- Description:	Lista di Province per Regione
-- =============================================
CREATE PROCEDURE [pazienti_ws].[IstatProvinceByRegione]
	@Nome varchar(64)
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		  IstatProvince.Codice
		, IstatProvince.Nome
		, IstatProvince.Sigla
		, IstatProvince.CodiceRegione

	FROM 
		dbo.IstatProvince
	INNER JOIN 
		dbo.IstatRegioni ON IstatProvince.CodiceRegione = IstatRegioni.Codice
	
	WHERE
			(IstatRegioni.Nome LIKE @Nome OR @Nome IS NULL)
		AND (IstatProvince.Nome NOT LIKE '%{Codice Sconosciuto}%')
	
END