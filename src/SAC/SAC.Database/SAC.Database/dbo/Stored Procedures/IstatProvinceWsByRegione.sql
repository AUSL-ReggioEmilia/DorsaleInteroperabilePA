
CREATE PROCEDURE [dbo].[IstatProvinceWsByRegione]
	@Nome varchar(64)

AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	IF RIGHT(@Nome, 1) = '*'
		BEGIN
			SET @Nome = SUBSTRING(@Nome, 1, LEN(@Nome)-1) + '%'
		END


	SELECT 
		  IstatProvince.Codice
		, IstatProvince.Nome
		, IstatProvince.Sigla
		, IstatProvince.CodiceRegione

	FROM 
		IstatProvince

		INNER JOIN IstatRegioni ON IstatProvince.CodiceRegione = IstatRegioni.Codice
	
	WHERE
			(IstatRegioni.Nome LIKE @Nome OR @Nome IS NULL)
		AND (IstatProvince.Nome NOT LIKE '%{Codice Sconosciuto}%')
	
END
















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatProvinceWsByRegione] TO [DataAccessWs]
    AS [dbo];

