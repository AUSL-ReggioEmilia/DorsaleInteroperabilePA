

/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/
CREATE VIEW [dbo].[PrestazioniAttributi]
AS
	SELECT IdPrestazioniBase, Nome, Valore, DataPartizione
	FROM store.PrestazioniAttributi

GO
GRANT SELECT
    ON OBJECT::[dbo].[PrestazioniAttributi] TO [DataAccessSql]
    AS [dbo];

