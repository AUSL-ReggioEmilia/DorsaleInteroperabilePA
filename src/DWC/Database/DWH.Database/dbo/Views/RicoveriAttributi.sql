
/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/
CREATE VIEW [dbo].[RicoveriAttributi]
AS
	SELECT IdRicoveriBase, Nome, Valore, DataPartizione
	FROM store.RicoveriAttributi


GO
GRANT SELECT
    ON OBJECT::[dbo].[RicoveriAttributi] TO [DataAccessSql]
    AS [dbo];

