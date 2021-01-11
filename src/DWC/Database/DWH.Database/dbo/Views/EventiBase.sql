
/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/
CREATE VIEW [dbo].[EventiBase]
AS

	SELECT Id, IdEsterno, DataModificaEsterno
		, IdPaziente, DataInserimento, DataModifica
		, AziendaErogante, SistemaErogante, RepartoErogante
		, DataEvento, StatoCodice, TipoEventoCodice, TipoEventoDescr
		, NumeroNosologico, TipoEpisodio, RepartoCodice, RepartoDescr
		, Diagnosi, DataPartizione
	FROM store.EventiBase

GO
GRANT SELECT
    ON OBJECT::[dbo].[EventiBase] TO [DataAccessSql]
    AS [dbo];

