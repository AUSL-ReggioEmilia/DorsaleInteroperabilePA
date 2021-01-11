

CREATE VIEW [DataAccess].[EventiAttributi] AS
/*
	CREATA DA SANDRO 2015-09-24: 
		Nuova vista ad uso esclusivo accesso ESTERNO
		Utilizzo nuova vista store.EventiAttributi
*/
SELECT IdEventiBase, DataPartizione, Nome, Valore
  FROM [store].[EventiAttributi] WITH(NOLOCK)
