
/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/
CREATE VIEW [dbo].[EventiAttributi]
AS
	SELECT IdEventiBase, Nome, Valore, DataPartizione
	FROM store.EventiAttributi

GO
GRANT SELECT
    ON OBJECT::[dbo].[EventiAttributi] TO [DataAccessSql]
    AS [dbo];

