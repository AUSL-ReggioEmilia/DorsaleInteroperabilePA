
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-03-07
-- Modify date: 2014-02-14 Nuova versione senza date sis e ticket
-- Modify date: 2018-06-12 Ordina i dati per inserimento usando TS
--							Serve per mantenere inalterata la sequenza dei nodi xml
--
-- Description:	Seleziona le riga ordine erogate by idordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheErogateSelectByIDOrdineErogato3]
	@IDOrdineErogatoTestata uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	SELECT R.ID
		, R.IDOrdineErogatoTestata
		, R.StatoOrderEntry
		, R.DataModificaStato
		, R.IDPrestazione
		, P.Codice AS CodicePrestazione
		, P.Descrizione AS DescrizionePrestazione			
		, R.IDRigaRichiedente
		, R.IDRigaErogante
		, R.StatoErogante
		, R.Data
		, R.Operatore
		, R.Consensi
	FROM OrdiniRigheErogate R
		INNER JOIN Prestazioni P ON R.IDPrestazione = P.ID
	WHERE R.IDOrdineErogatoTestata = @IDOrdineErogatoTestata
	ORDER BY R.TS

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniRigheErogateSelectByIDOrdineErogato3] TO [DataAccessWs]
    AS [dbo];

