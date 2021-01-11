
CREATE VIEW [DataAccess].[PrestazioniAttributi] AS
/*
	CREATA DA SANDRO 2015-09-24: 
		Nuova vista ad uso esclusivo accesso ESTERNO
		Utilizzo nuova vista store.PrestazioniAttributiReferto

	MODIFICATE 2016-10-07 SANDRO: Converto in nVARCHAR perche XML non permette le query distribuite

*/
SELECT IdRefertiBase, DataPartizione, IdPrestazioniBase, Nome, Valore
  FROM [store].[PrestazioniAttributiReferto] WITH(NOLOCK)
