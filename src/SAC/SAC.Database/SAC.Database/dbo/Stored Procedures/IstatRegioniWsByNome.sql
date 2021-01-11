
CREATE PROCEDURE [dbo].[IstatRegioniWsByNome]
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
		Codice, Nome

	FROM 
		IstatRegioni
	
	WHERE
			(Nome LIKE @Nome OR @Nome IS NULL)
		AND (Nome NOT LIKE '%{Codice Sconosciuto}%')

END













GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatRegioniWsByNome] TO [DataAccessWs]
    AS [dbo];

