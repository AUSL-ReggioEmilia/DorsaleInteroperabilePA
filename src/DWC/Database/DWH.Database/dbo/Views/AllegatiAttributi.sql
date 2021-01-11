
/*
MODIFICA SANDRO 2015-08-19: Vista di compatibilità
							per ora la vista deve rimanere UPDATABILE

*/
CREATE VIEW [dbo].[AllegatiAttributi]
AS
	SELECT IdAllegatiBase, Nome, Valore, DataPartizione
	FROM store.AllegatiAttributi

GO
GRANT SELECT
    ON OBJECT::[dbo].[AllegatiAttributi] TO [DataAccessSql]
    AS [dbo];

