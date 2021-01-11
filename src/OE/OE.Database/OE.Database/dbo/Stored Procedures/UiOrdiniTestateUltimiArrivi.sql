-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-10-15
-- Modify date: 
-- Description: Lista raggruppata per azienda/sistema degli ordini ricevuti modificati nelle ultime x ore
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniTestateUltimiArrivi]
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
		dbo.OrdiniTestate O WITH (NOLOCK)
	INNER JOIN 
		dbo.Sistemi S WITH (NOLOCK) ON O.IDSistemaRichiedente = S.ID
				
	WHERE 
		DataModifica > DATEADD(HOUR, @NumeroOre, GETDATE())		

	GROUP BY 
		S.CodiceAzienda, S.Codice
	ORDER BY 
		S.CodiceAzienda, S.Codice

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniTestateUltimiArrivi] TO [DataAccessUi]
    AS [dbo];

