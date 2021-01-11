CREATE VIEW [DataAccess].[RefertiAttributi] AS
/*
	CREATA DA SANDRO 2015-09-24: 
		Nuova vista ad uso esclusivo accesso ESTERNO
		Utilizzo nuova vista store.RefertiAttributi
*/
SELECT IdRefertiBase, DataPartizione, Nome, Valore
  FROM [store].[RefertiAttributi] WITH(NOLOCK)
