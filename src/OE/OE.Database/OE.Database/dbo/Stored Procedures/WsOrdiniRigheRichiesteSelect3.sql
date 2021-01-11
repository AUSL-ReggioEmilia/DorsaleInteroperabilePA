

-- =============================================
-- Author:		Alesasndro Nostini
-- Create date: 2012-06-05
-- Modify date: 2014-02-14 Nuova versione senza Data di sistema e Ticket
-- Modify date: 2018-06-12 Ordina i dati per inserimento usando TS
--							Serve per mantenere inalterata la sequenza dei nodi xml
--
-- Description:	Seleziona una riga ordine richiesta by riga richiedente
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteSelect3]
	  @IDOrdineTestata uniqueidentifier
	, @IDRigaRichiedente varchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		  R.ID
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
		INNER JOIN Prestazioni P ON R.IDPrestazione = P.ID
		
		INNER JOIN Sistemi S ON R.IDSistemaErogante = S.ID
		INNER JOIN Aziende A ON S.CodiceAzienda = A.Codice
		
	WHERE 	R.IDOrdineTestata = @IDOrdineTestata
		AND R.IDRigaRichiedente = @IDRigaRichiedente
	ORDER BY R.TS

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteSelect3] TO [DataAccessWs]
    AS [dbo];

