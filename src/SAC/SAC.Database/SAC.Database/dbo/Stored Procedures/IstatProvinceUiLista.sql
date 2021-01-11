

CREATE PROCEDURE [dbo].[IstatProvinceUiLista]
(
	@Codice varchar(6) = NULL,
	@Nome varchar(128) = NULL,
	@CodiceRegione varchar(2) = NULL
)
WITH RECOMPILE
AS

BEGIN
	SET NOCOUNT OFF
  
	SELECT 
		P.Codice
		,P.Nome
		,P.Sigla
		,P.CodiceRegione
		,R.Nome AS Regione
	FROM 
		IstatProvince P
	INNER JOIN
		IstatRegioni R 
			ON P.CodiceRegione = R.Codice
			
	WHERE 
		(P.Codice = @Codice OR @Codice IS NULL) AND
		(P.Nome LIKE @Nome + '%' OR @Nome IS NULL) AND 
		(P.CodiceRegione = @CodiceRegione OR @CodiceRegione IS NULL) AND
		(P.Codice NOT IN ('-1','-10'))
		
	ORDER BY 
		P.Nome

END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatProvinceUiLista] TO [DataAccessUi]
    AS [dbo];

