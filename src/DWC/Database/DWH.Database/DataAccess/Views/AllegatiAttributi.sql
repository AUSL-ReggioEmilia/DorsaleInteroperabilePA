

CREATE VIEW [DataAccess].[AllegatiAttributi] AS
/*
	CREATA DA SANDRO 2015-09-24: 
		Nuova vista ad uso esclusivo accesso ESTERNO
		Utilizzo nuova vista store.AllegatiAttributiReferto
*/
SELECT IdRefertiBase, DataPartizione, IdAllegatiBase, Nome, Valore
  FROM [store].[AllegatiAttributiReferto] WITH(NOLOCK)
