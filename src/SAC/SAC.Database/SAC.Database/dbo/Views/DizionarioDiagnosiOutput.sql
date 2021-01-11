
CREATE VIEW [dbo].[DizionarioDiagnosiOutput]
AS
--
-- Modifica Ettore 2014-04-02: 
--		Ho sostituito alla tabella DizionariLhaDiagnosi l'alias verso l'analoga tabella in SacConnLha
--
	SELECT
		  CodiceEsenzione
		, CodiceDiagnosi
		, CodiceTestoEsenzione
		, DescrizioneDiagnosi
		, TimestampUltimaModifica

	FROM
		SacConnLha_DizionariLhaDiagnosi


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioDiagnosiOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioDiagnosiOutput] TO [DataAccessDizionari]
    AS [dbo];

