
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-06-05
-- Modify date: 2014-02-14 Nuova versione denza data sis e ticket
-- Modify date: 2018-06-12 Ordina i dati per inserimento usando TS
--							Serve per mantenere inalterata la sequenza dei nodi xml
--
-- Description:	Seleziona le riga ordine richieste by idordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteSelectByIDOrdine4]
	@IDOrdineTestata uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  R.ID
		, R.IDOrdineTestata
		, R.StatoOrderEntry
		, R.DataModificaStato
		, R.IDPrestazione
		, P.Codice AS CodicePrestazione
		, P.Descrizione AS DescrizionePrestazione
		, P.Tipo AS TipoPrestazione
		, R.IDSistemaErogante
		, S.Codice AS CodiceSistemaErogante
		, S.Descrizione AS DescrizioneSistemaErogante
		, A.Codice AS CodiceAziendaSistemaErogante
		, A.Descrizione AS DescrizioneAziendaSistemaErogante
		, R.IDRigaOrderEntry
		, R.IDRigaRichiedente
		, R.IDRigaErogante
		, R.IDRichiestaErogante
		, R.StatoRichiedente
		, R.Consensi
		
	FROM OrdiniRigheRichieste R
		INNER JOIN Sistemi S ON R.IDSistemaErogante = S.ID
		INNER JOIN Aziende A ON S.CodiceAzienda = A.Codice
		INNER JOIN Prestazioni P ON R.IDPrestazione = P.ID
		
	WHERE IDOrdineTestata = @IDOrdineTestata
	ORDER BY R.TS
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteSelectByIDOrdine4] TO [DataAccessWs]
    AS [dbo];

