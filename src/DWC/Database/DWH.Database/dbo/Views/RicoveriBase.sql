
/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/

CREATE VIEW [dbo].[RicoveriBase]
AS
	SELECT Id, IdEsterno, DataModificaEsterno, DataInserimento, DataModifica
			, StatoCodice, Cancellato, NumeroNosologico
			, AziendaErogante, SistemaErogante, RepartoErogante, IdPaziente
			, OspedaleCodice, OspedaleDescr, TipoRicoveroCodice, TipoRicoveroDescr
			, Diagnosi, DataAccettazione
			, RepartoAccettazioneCodice, RepartoAccettazioneDescr
			, DataTrasferimento, RepartoCodice, RepartoDescr
			, SettoreCodice, SettoreDescr, LettoCodice
			, DataDimissione, DataPartizione
	FROM store.RicoveriBase

GO
GRANT SELECT
    ON OBJECT::[dbo].[RicoveriBase] TO [DataAccessSql]
    AS [dbo];

