


CREATE VIEW [dbo].[DizionarioRegioniOutput]
AS
--
-- Modifica Ettore 2014-04-02: 
--		Ho sostituito alla tabella DizionariLhaRegioni l'alias verso l'analoga tabella in SacConnLha
--
	SELECT CodiceRegione
		, DescrizioneRegione
		, TimestampUltimaModifica
	FROM SacConnLha_DizionariLhaRegioni WITH(NOLOCK)

	UNION

	SELECT CONVERT(NVARCHAR(3), Codice + '0') AS CodiceRegione
			,CONVERT(NVARCHAR(40),Nome) AS DescrizioneRegione
			,CONVERT(DATETIME, NULL) AS TimestampUltimaModifica

	  FROM IstatRegioni WITH(NOLOCK)
	  WHERE NOT Codice + '0' IN (
			SELECT CodiceRegione
			FROM SacConnLha_DizionariLhaRegioni WITH(NOLOCK)
			)



GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioRegioniOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioRegioniOutput] TO [DataAccessDizionari]
    AS [dbo];

