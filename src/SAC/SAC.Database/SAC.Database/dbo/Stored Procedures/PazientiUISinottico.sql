
-- =============================================
-- Author:		Ettore
-- Create date: 2017-05-09
-- Description:	Restituisce numero di anagrafiche modificate nel periodo specificato raggruppate per provenienza
--				e mostra la somma delle anagrafuche nello stato attivo , fuso, cancellato
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUISinottico]
(
	@DataDal DATETIME
	, @DataAl DATETIME 
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @DataDal IS NULL
	BEGIN 
		RAISERROR('Il parametro @DataDal è obbligatorio', 16, 1)
		RETURN
	END
		
	IF @DataAl IS NULL SET @DataAl = GETDATE()
			
	SELECT
		 GROUPING(Provenienza) as IsTotale
		,Provenienza
		,SUM(CASE WHEN Disattivato = 0 THEN 1 ELSE NULL END) as Attivi
		,SUM(CASE WHEN Disattivato = 1 THEN 1 ELSE NULL END) as Cancellati
		,SUM(CASE WHEN Disattivato = 2 THEN 1 ELSE NULL END) as Fusi
	FROM 
		[dbo].[Pazienti] with(nolock)
	WHERE 
		DataModifica BETWEEN @DataDal AND @DataAl
	GROUP BY
		ROLLUP(Provenienza) 
	ORDER BY 
		GROUPING(Provenienza), Provenienza

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUISinottico] TO [DataAccessUi]
    AS [dbo];

