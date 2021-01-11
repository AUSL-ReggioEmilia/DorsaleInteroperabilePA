-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-10-16
-- Modify date: 
-- Description: Lista raggruppata per azienda/sistema degli ordini erogati modificati nelle ultime x ore
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniErogatiTestateUltimiArrivi]
(
 @NumeroOre INT --FILTRA SOLO GLI ORDINI MODIFICATI NON PIU' DI TOT ORE FA
)
AS
BEGIN
  SET NOCOUNT OFF

	SET @NumeroOre = @NumeroOre * -1
	
	SELECT 
		  S.CodiceAzienda
		, S.Codice AS CodiceSistema
		, MAX(O.DataModifica) AS DataModifica
		, COUNT(O.ID) AS [Count]
	FROM 
		dbo.OrdiniErogatiTestate O WITH (NOLOCK)
	INNER JOIN 
		dbo.Sistemi S WITH (NOLOCK) ON O.IDSistemaErogante = S.ID
				
	WHERE 
		DataModifica > DATEADD(HOUR, @NumeroOre, GETDATE())		

	GROUP BY 
		S.CodiceAzienda, S.Codice
	ORDER BY 
		S.CodiceAzienda, S.Codice

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniErogatiTestateUltimiArrivi] TO [DataAccessUi]
    AS [dbo];

