

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-03-07
-- Modify date: 2014-02-14 Nuova versione senza dati sis e ticket
-- Modify date: 2018-06-12 Ordina i dati per inserimento usando IDSplit
--							Serve per mantenere inalterata la sequenza dei nodi xml
--
-- Description:	Seleziona una testata ordine erogato per protocollo richiesta
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniErogatiTestateSelectByProtocollo5]
	  @Anno int
	, @Numero int
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT *
	FROM [WsOrdiniErogatiTestateSelect] TE
	WHERE TE.Anno = @Anno
		AND TE.Numero = @Numero
	ORDER BY ISNULL(TE.IDSplit, 0)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniErogatiTestateSelectByProtocollo5] TO [DataAccessWs]
    AS [dbo];

