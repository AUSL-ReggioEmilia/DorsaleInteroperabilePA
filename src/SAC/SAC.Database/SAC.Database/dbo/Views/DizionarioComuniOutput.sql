


CREATE VIEW [dbo].[DizionarioComuniOutput]
AS
--
-- Modifica Ettore 2014-04-02: 
--		Ho sostituito alla tabella DizionariLhaComuni l'alias verso l'analoga tabella in SacConnLha
--		Ho sostituito come default della data di attivazione il valore '1800-01-01' al posto di '1900-01-01' (LHA usa '1800-01-01' come data minima)
--
	SELECT 	  CodiceInternoComune
			, DescrizioneComune
			, IstatComune
			, CodiceDistretto
			, DataInizioValidita
			, DataFineValidita
			, Cap
			, CodiceCatastale
			, CodiceRegione
			, CodiceProvincia
			, CodiceAsl
			, FlagComuneStatoEstero
			, FlagStatoEsteroUE
			, TimestampUltimaModifica
	FROM SacConnLha_DizionariLhaComuni WITH(NOLOCK) 
		WHERE Disattivato = 0

	UNION
 
  	SELECT CONVERT(NUMERIC(6,0), 0) AS CodiceInternoComune
			,CONVERT(NVARCHAR(35), [IstatComuni].Nome) AS DescrizioneComune
			,CONVERT(VARCHAR(6), [IstatComuni].Codice) AS IstatComune
			,CONVERT(NVARCHAR(5), NULL) AS CodiceDistretto
			,CONVERT(DATETIME, '1800-01-01') AS DataInizioValidita
			,CONVERT(DATETIME, '3000-01-01') AS DataFineValidita
			,CONVERT(NVARCHAR(7), NULL) AS Cap
			,CONVERT(NVARCHAR(4), NULL) AS CodiceCatastale
			,CONVERT(VARCHAR(3), NULLIF([IstatProvince].CodiceRegione, '-1')) AS CodiceRegione
			,CONVERT(NVARCHAR(2), NULLIF([IstatProvince].Sigla, '??')) AS CodiceProvincia
			,CONVERT(NUMERIC(3,0), IstatAsl.Codice) AS CodiceAsl
			,CONVERT(NVARCHAR(1), CASE [IstatComuni].Nazione WHEN 1 THEN 'E' ELSE 'C' END) AS FlagComuneStatoEstero
			,CONVERT(NVARCHAR(1), NULL) AS FlagStatoEsteroUE
			,CONVERT(DATETIME, NULL) AS TimestampUltimaModifica
			
	  FROM [dbo].[IstatComuni] WITH(NOLOCK)
		LEFT OUTER JOIN [dbo].[IstatProvince] WITH(NOLOCK)
			ON [IstatComuni].CodiceProvincia = [IstatProvince].Codice
		
		LEFT OUTER JOIN (SELECT MIN([Codice]) AS [Codice]
							  ,[CodiceComune]
							  ,[CodiceAslRegione]
						  FROM [dbo].[IstatAsl]  WITH(NOLOCK)
						  GROUP BY  [CodiceComune],[CodiceAslRegione]) IstatAsl
			ON [IstatProvince].CodiceRegione + '0' = IstatAsl.CodiceAslRegione
				AND [IstatComuni].Codice = IstatAsl.CodiceComune
					
	  WHERE NOT [IstatComuni].Codice IN (
			SELECT IstatComune
			FROM SacConnLha_DizionariLhaComuni WITH(NOLOCK)
			)


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioComuniOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioComuniOutput] TO [DataAccessDizionari]
    AS [dbo];

