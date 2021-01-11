
/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/

CREATE VIEW [dbo].[RefertiBaseRiferimenti]
AS
	SELECT Id, DataPartizione, IdRefertiBase, IdEsterno
		, DataInserimento, DataModificaEsterno
	FROM store.RefertiBaseRiferimenti

GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiBaseRiferimenti] TO [DataAccessSql]
    AS [dbo];

