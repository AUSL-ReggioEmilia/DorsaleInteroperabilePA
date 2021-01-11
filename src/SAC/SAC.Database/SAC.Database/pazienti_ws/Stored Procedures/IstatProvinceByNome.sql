

-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-12-21
-- Description:	Lista di Province per Nome
-- =============================================
CREATE PROCEDURE [pazienti_ws].[IstatProvinceByNome]
	  @Nome varchar(64)
	, @CodiceRegione varchar(2)
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		  Codice
		, Nome
		, Sigla
		, CodiceRegione
	FROM 
		dbo.IstatProvince	
	WHERE
			(Nome LIKE @Nome OR @Nome IS NULL)
		AND (CodiceRegione = @CodiceRegione OR @CodiceRegione IS NULL)
		AND (Nome NOT LIKE '%{Codice Sconosciuto}%')
	
END