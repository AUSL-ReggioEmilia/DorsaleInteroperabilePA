
CREATE VIEW [dbo].[DizionarioMediciOutput]
AS
--
-- Modifica Ettore 2014-04-02: 
--		Ho sostituito alla tabella DizionariLhaMedici l'alias verso l'analoga tabella in SacConnLha
--
	SELECT 
		  CodiceInterno
		, CodiceRegionale
		, CognomeNome
		, CodiceFiscale
		, Sesso
		, DataNascita
		, CodiceTipoMedico
		, DescrizioneTipoMedico
		, DataCessazione
		, TimestampUltimaModifica

	FROM 
		SacConnLha_DizionariLhaMedici


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioMediciOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioMediciOutput] TO [DataAccessDizionari]
    AS [dbo];

