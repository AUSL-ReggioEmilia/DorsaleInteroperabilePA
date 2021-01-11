

-- =============================================
-- Author:		Ettore
-- Create date: 2017-05-09
-- Description:	Restituisce numero di consensi inseriti nel periodo specificato raggruppate per provenienza
--				e mostra la somma dei vari tipi di consenso e il loro stato
-- =============================================
CREATE PROCEDURE [dbo].[ConsensiUISinottico]
(
	@DataDal DATETIME
	, @DataAl DATETIME 
)
AS
BEGIN
	SET NOCOUNT ON;
	/*
	--TABELLA ConsensiTipo
		Id	Nome
		2	Dossier
		3	DossierStorico
		1	Generico
		10	SOLE-LIVELLO0
		11	SOLE-LIVELLO1
		12	SOLE-LIVELLO2
		15	SOLE-STATO-A
		19	SOLE-STATO-C
		16	SOLE-STATO-N
		17	SOLE-STATO-R
		18	SOLE-STATO-S
	*/

	IF @DataDal IS NULL
	BEGIN 
		RAISERROR('Il parametro @DataDal è obbligatorio', 16, 1)
		RETURN
	END
		
	IF @DataAl IS NULL SET @DataAl = GETDATE()
			
	SELECT
		 GROUPING(Provenienza) as IsTotale
		, GROUPING(Stato) AS IsSubTotale
		, Provenienza
		, Stato
		,SUM(CASE WHEN IdTipo = 1 THEN 1 ELSE NULL END) as NumGenerico
		,SUM(CASE WHEN IdTipo = 2 THEN 1 ELSE NULL END) as NumDossier
		,SUM(CASE WHEN IdTipo = 3 THEN 1 ELSE NULL END) as NumStorico
		,SUM(CASE WHEN IdTipo = 10 THEN 1 ELSE NULL END) as SOLE_LIVELLO_0
		,SUM(CASE WHEN IdTipo = 11 THEN 1 ELSE NULL END) as SOLE_LIVELLO_1
		,SUM(CASE WHEN IdTipo = 12 THEN 1 ELSE NULL END) as SOLE_LIVELLO_2
		,SUM(CASE WHEN IdTipo = 15 THEN 1 ELSE NULL END) as SOLE_STATO_A
		,SUM(CASE WHEN IdTipo = 16 THEN 1 ELSE NULL END) as SOLE_STATO_N
		,SUM(CASE WHEN IdTipo = 17 THEN 1 ELSE NULL END) as SOLE_STATO_R
		,SUM(CASE WHEN IdTipo = 18 THEN 1 ELSE NULL END) as SOLE_STATO_S
		,SUM(CASE WHEN IdTipo = 19 THEN 1 ELSE NULL END) as SOLE_STATO_C
		--, COUNT(*) AS Totale
	FROM 
		dbo.Consensi with(nolock)
	WHERE 
		DataInserimento BETWEEN @DataDal AND @DataAl
	GROUP BY
		ROLLUP ((Provenienza) , (Stato))
	ORDER BY 
		GROUPING(Provenienza), Provenienza
		, GROUPING(Stato) DESC

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiUISinottico] TO [DataAccessUi]
    AS [dbo];

