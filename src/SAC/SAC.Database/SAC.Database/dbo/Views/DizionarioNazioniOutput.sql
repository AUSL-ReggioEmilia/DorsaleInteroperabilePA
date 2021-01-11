

CREATE VIEW [dbo].[DizionarioNazioniOutput]
AS
	SELECT CodiceInternoNazione
			, DescrizioneNazione
			, IstatNazione
			, DataInizioValidita
			, DataFineValidita
			, FlagPaeseUE
			, TimestampUltimaModifica
	FROM SacConnLha_DizionariLhaNazioni

	UNION

	SELECT CONVERT(NVARCHAR(3), Codice) AS CodiceInternoNazione
			,CONVERT(NVARCHAR(40),Nome) AS DescrizioneNazione
			,CONVERT(VARCHAR(3), Codice) AS IstatNazione
			,CONVERT(DATETIME, '1900-01-01') AS DataInizioValidita
			,CONVERT(DATETIME, '3000-01-01') AS DataFineValidita
			,CONVERT(NVARCHAR(1), NULL) AS FlagPaeseUE
			,CONVERT(DATETIME, NULL) AS TimestampUltimaModifica

	  FROM IstatNazioni WITH(NOLOCK)
	  WHERE NOT Codice IN (
			SELECT IstatNazione
			FROM SacConnLha_DizionariLhaNazioni WITH(NOLOCK)
			)


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioNazioniOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioNazioniOutput] TO [DataAccessDizionari]
    AS [dbo];

