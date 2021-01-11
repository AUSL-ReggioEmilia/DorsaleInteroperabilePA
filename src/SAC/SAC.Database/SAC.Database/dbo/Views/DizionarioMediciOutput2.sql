


CREATE VIEW [dbo].[DizionarioMediciOutput2]
AS
--
-- Creata da Ettore 2014-04-02: 
-- Nuova versione: aggiunto i nuovi campi CodiceDistretto e DescrizioneDistretto del medico
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
		--Modifica Ettore 2016-11-10
		,CodiceDistretto
		,DescrizioneDistretto
	FROM 
		SacConnLha_DizionariLhaMedici
GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioMediciOutput2] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioMediciOutput2] TO [DataAccessDizionari]
    AS [dbo];

