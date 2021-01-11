
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-04-04
-- Modify date: 2014-02-14 Nuova versione senza dati sis e ticket
-- Modify date: 2018-06-12 Ordina i dati per inserimento usando IDSplit
--							Serve per mantenere inalterata la sequenza dei nodi xml
--
-- Description:	Seleziona una testata ordine erogato per idrichiestarichiedente + sistema richiedente
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniErogatiTestateSelectByIDOrdine2]
	@IDOrdineTestata uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT *
	FROM [WsOrdiniErogatiTestateSelect] TE
	WHERE TE.IDOrdineTestata = @IDOrdineTestata
	ORDER BY ISNULL(TE.IDSplit, 0)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniErogatiTestateSelectByIDOrdine2] TO [DataAccessWs]
    AS [dbo];

