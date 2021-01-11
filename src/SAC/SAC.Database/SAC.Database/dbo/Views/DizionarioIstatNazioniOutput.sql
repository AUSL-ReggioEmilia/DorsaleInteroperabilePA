



CREATE VIEW [dbo].[DizionarioIstatNazioniOutput]
AS
/*
	Modifica Ettore 2014-05-20: tolto i campi Obsoleto e ObsoletoData (li restituisco usando i nuovi campi)
*/
	SELECT 
		Codice
		, Nome
		, CASE 
			WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
			END AS Obsoleto
		, DataFineValidita AS ObsoletoData
	FROM 
		IstatNazioni


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioIstatNazioniOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioIstatNazioniOutput] TO [DataAccessDizionari]
    AS [dbo];

