
/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/
CREATE VIEW [dbo].[RefertiAttributi]
AS
	SELECT IdRefertiBase, Nome, Valore, DataPartizione
	FROM store.RefertiAttributi

GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiAttributi] TO [DataAccessSql]
    AS [dbo];

