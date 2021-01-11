


CREATE VIEW [DataAccess].[RicoveriAttributi] AS
/*
	CREATA DA SANDRO 2015-09-24: 
		Nuova vista ad uso esclusivo accesso ESTERNO
		Utilizzo nuova vista store.EventiAttributi
*/
SELECT IdRicoveriBase, DataPartizione, Nome, Valore
  FROM [store].[RicoveriAttributi] WITH(NOLOCK)
