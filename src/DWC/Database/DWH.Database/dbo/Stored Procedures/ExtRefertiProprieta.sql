/*
Ritorna i dati principali del referto
Modificato SANDRO 2015-08-20: Usa la VIEW store

MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetRefertiPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]

*/
CREATE PROCEDURE [dbo].[ExtRefertiProprieta]
	@IdEsterno as varchar(64)
AS
BEGIN
	SET NOCOUNT ON

	SELECT rb.IdEsterno
		, rb.DataInserimento
		, rb.DataModifica
		, rb.DataModificaEsterno
		, rb.AziendaErogante
		, rb.SistemaErogante
		, rb.RepartoErogante
		, rb.DataReferto
		, rb.NumeroReferto
		, rb.Cancellato
		, rb.StatoRichiestaCodice
		, rb.RepartoRichiedenteCodice
		, rb.RepartoRichiedenteDescr
		, (SELECT COUNT(*) FROM store.PrestazioniBase WITH(NOLOCK) WHERE IdRefertiBase = rb.Id ) AS Prestazioni
		, (SELECT COUNT(*) FROM store.AllegatiBase WITH(NOLOCK) WHERE IdRefertiBase = rb.Id ) AS Allegati

	-- Legge la PK del referto (NOLOCK) e ritorna su [store].RefertiBase
	FROM [store].RefertiBase rb
		INNER JOIN [dbo].[GetRefertiPk](RTRIM(@IdEsterno)) PK
			ON rb.Id = PK.ID
			AND rb.DataPartizione = PK.DataPartizione

--DA VERIFICARE PERCHE' ACCEDEVA DIRETTAMETE SENZA [GetRefertiId] che cerca anche nei Riferimenti

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiProprieta] TO [ExecuteExt]
    AS [dbo];

