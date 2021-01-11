
CREATE PROCEDURE [dbo].[IstatProvinceWsByNome]
	  @Nome varchar(64)
	, @CodiceRegione varchar(2)

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
		Codice, Nome, Sigla, CodiceRegione

	FROM 
		IstatProvince
	
	WHERE
			(Nome LIKE @Nome OR @Nome IS NULL)
		AND (CodiceRegione = @CodiceRegione OR @CodiceRegione IS NULL)
		AND (Nome NOT LIKE '%{Codice Sconosciuto}%')
	
END
















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatProvinceWsByNome] TO [DataAccessWs]
    AS [dbo];

