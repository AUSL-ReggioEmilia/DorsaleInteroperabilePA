

CREATE VIEW [dbo].[DizionarioEsenzioniOutput]
AS
/*
	Modifica Ettore 2014-04-02: 
		Ho sostituito alla tabella DizionariLhaEsenzioni l'alias verso l'analoga tabella in SacConnLha
	Modifica Ettore 2017-05-11: 
		Aggiunto al dizionario delle esenzioni le esenzioni da fasce di reddito
*/

	SELECT
		  CodiceEsenzione
		, DescrizioneEsenzione
		, NoteEsenzione
		, CodiceTipoEsenzione
		, QuotaFissa
		, DataScadenzaEsenzione
		, Prescrivibile
		, GiorniValidita
		, EtaMinima
		, EtaMassima
		, TimestampUltimaModifica
	FROM
		SacConnLha_DizionariLhaEsenzioni
	UNION
	SELECT
		  Codice AS CodiceEsenzione
		, Descrizione AS DescrizioneEsenzione
		, NULL AS NoteEsenzione
		, '' AS CodiceTipoEsenzione
		, '' AS QuotaFissa
		, NULL AS DataScadenzaEsenzione
		, '' AS Prescrivibile
		, NULL AS GiorniValidita
		, NULL AS EtaMinima
		, NULL EtaMassima
		--NON ABBIAMO QUESTO DATO E IL CAMPO NON E' NULLABILE: restituisco la data minima di SqlServer
		, CAST('1753-01-01' AS DATETIME) AS TimestampUltimaModifica 
	FROM
		SacConnLHA_DizionariLhaFasceReddito


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioEsenzioniOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioEsenzioniOutput] TO [DataAccessDizionari]
    AS [dbo];

