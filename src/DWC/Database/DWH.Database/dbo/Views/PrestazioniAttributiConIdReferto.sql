
/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/
CREATE VIEW [dbo].[PrestazioniAttributiConIdReferto]
AS
	SELECT IdRefertiBase, IdPrestazioniBase, DataPartizione, Nome, Valore
	FROM store.PrestazioniAttributiReferto

GO
GRANT SELECT
    ON OBJECT::[dbo].[PrestazioniAttributiConIdReferto] TO [DataAccessSql]
    AS [dbo];

