

-- =============================================
-- Author:		Stefano P
-- Create date: 2016-10-26
-- Description:	Lista regioni cercando per nome
-- =============================================
CREATE PROCEDURE [pazienti_ws].[IstatRegioniByNome]
	@Nome varchar(64)
AS
BEGIN

	SET NOCOUNT ON

	SELECT 
		  Codice
		, Nome
	FROM 
		dbo.IstatRegioni	
	WHERE
			(Nome LIKE @Nome OR @Nome IS NULL)
		AND (Nome NOT LIKE '%{Codice Sconosciuto}%')

END