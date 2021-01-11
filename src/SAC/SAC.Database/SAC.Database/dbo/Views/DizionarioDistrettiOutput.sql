

CREATE VIEW [dbo].[DizionarioDistrettiOutput]
AS
--
-- Modifica Ettore 2014-04-02: 
--		Ho sostituito alla tabella DizionariLhaDistretti l'alias verso l'analoga tabella in SacConnLha
--
	SELECT
		CodiceDistretto
		, DescrizioneDistretto
		, TimestampUltimaModifica
	FROM
		SacConnLha_DizionariLhaDistretti


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioDistrettiOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioDistrettiOutput] TO [DataAccessDizionari]
    AS [dbo];

