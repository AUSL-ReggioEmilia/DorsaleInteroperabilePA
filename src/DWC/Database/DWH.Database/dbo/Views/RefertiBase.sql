
/*
MODIFICA SANDRO 2015-09-31: Vista di compatibilità
							Accede tramite lo schema STORE
*/

CREATE VIEW [dbo].[RefertiBase]
AS
	SELECT Id, DataPartizione, IdEsterno, IdPaziente, DataInserimento, DataModifica
		, AziendaErogante, SistemaErogante, RepartoErogante
		, DataReferto, NumeroReferto, NumeroNosologico, Cancellato
		, NumeroPrenotazione, DataModificaEsterno, StatoRichiestaCodice
		, RepartoRichiedenteCodice, RepartoRichiedenteDescr
		, IdOrderEntry, DataEvento, Firmato
	FROM store.RefertiBase

GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiBase] TO [ExecuteSole]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[RefertiBase] TO [DataAccessSql]
    AS [dbo];

