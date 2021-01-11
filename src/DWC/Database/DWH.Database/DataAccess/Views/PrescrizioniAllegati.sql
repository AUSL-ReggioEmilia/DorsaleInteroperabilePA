
CREATE VIEW [DataAccess].[PrescrizioniAllegati]
/*
	CREATA DA SANDRO 2015-09-24: 
		Nuova vista ad uso esclusivo accesso ESTERNO

	MODIFICATE 2016-10-07 SANDRO: Converto in nVARCHAR perche XML non permette le query distribuite
*/
AS
SELECT ID, DataPartizione, IdPrescrizioniBase, IdEsterno
		, DataInserimento, DataModifica
		, TipoContenuto
		, Contenuto
		, CONVERT(NVARCHAR(MAX), Attributi) AS Attributi
	FROM [store].[PrescrizioniAllegati] WITH(NOLOCK);