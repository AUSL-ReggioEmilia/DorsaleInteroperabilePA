

CREATE VIEW [dbo].[DizionarioAslOutput]
AS
--
-- Modifica Ettore 2014-04-03: 
--		Ho sostituito alla tabella DizionariLhaAsl l'alias verso l'analoga tabella in SacConnLha
--
	SELECT CodiceRegione
			, CodiceAsl
			, DescrizioneAsl
			, TimestampUltimaModifica
	FROM SacConnLha_DizionariLhaAsl

	UNION

	SELECT CONVERT(VARCHAR(3), LEFT( ia.CodiceRegione + '000', 3)) AS CodiceRegione
			,CONVERT(NUMERIC(3,0), ia.Codice) AS CodiceAsl
			,CONVERT(NVARCHAR(35),(SELECT TOP 1 ic.Nome
									FROM [dbo].[IstatComuni] ic
									WHERE ic.Codice = ia.CodiceComune
									)) AS DescrizioneAsl
			,CONVERT(DATETIME, NULL) AS TimestampUltimaModifica
	FROM (
			SELECT ia.Codice
				  ,MIN(ia.CodiceComune) AS CodiceComune
				  ,ip.CodiceRegione
				FROM [dbo].[IstatAsl] ia INNER JOIN [dbo].[IstatComuni] ic
						ON ia.CodiceComune = ic.Codice
										INNER JOIN [dbo].[IstatProvince] ip
						ON ic.CodiceProvincia = ip.Codice
				WHERE ip.CodiceRegione <> '-1'
				GROUP BY ia.Codice, ip.CodiceRegione
		  ) ia
	WHERE NOT (LEFT(ia.Codice + '000', 3) + '|' + LEFT( ia.CodiceRegione + '000', 3))
				 IN (
					SELECT RIGHT('000' + CONVERT(VARCHAR(3), CodiceAsl ), 3)+ '|' + CodiceRegione
					FROM SacConnLha_DizionariLhaAsl
					)




GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioAslOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioAslOutput] TO [DataAccessDizionari]
    AS [dbo];

