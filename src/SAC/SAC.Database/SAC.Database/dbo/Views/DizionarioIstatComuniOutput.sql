





CREATE VIEW [dbo].[DizionarioIstatComuniOutput]
AS
/*
	Modifica Ettore 2014-05-20: tolto i campi Obsoleto e ObsoletoData (li restituisco usando i nuovi campi)
	MODIFICA ETTORE 2017-03-27: restituito il campo CAP della tabella IstatNazioni (invece di fare join con tabella Pazienti)
								Tolto il DISTINCT
*/
	SELECT 
		  Codice
		, Nome
		, Cap
		, CodiceProvincia
		, CASE 
			WHEN GETDATE() BETWEEN ISNULL(DataInizioValidita, '1800-01-01') AND ISNULL(DataFineValidita, GETDATE()) THEN
				CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
		END AS Obsoleto
		, DataFineValidita AS ObsoletoData
	FROM 
		IstatComuni


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioIstatComuniOutput] TO [DataAccessSql]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionarioIstatComuniOutput] TO [DataAccessDizionari]
    AS [dbo];

