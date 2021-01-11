
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2011-10-26
-- Modify date: 2014-02-14 Nuova versione senza data sis e ticket
-- Modify date: 2017-10-12 Ordina i dati per inserimento usando il TS
--							Serve per mantenere inalterata la sequenza dei nodi xml
-- Description:	Seleziona un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateDatiAggiuntiviList2]
	  @IDOrdineTestata uniqueidentifier
	, @IDDatoAggiuntivo varchar(64)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT  ID
		  , IDOrdineTestata
		  , IDDatoAggiuntivo
		  , Nome
		  , TipoDato
		  , TipoContenuto
		  , ValoreDato
		  , ValoreDatoVarchar
		  , ValoreDatoXml
		  , ParametroSpecifico
		  , Persistente
	FROM OrdiniTestateDatiAggiuntivi
	WHERE IDOrdineTestata = @IDOrdineTestata
		AND (@IDDatoAggiuntivo IS NULL OR IDDatoAggiuntivo = @IDDatoAggiuntivo)
	ORDER BY TS
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateDatiAggiuntiviList2] TO [DataAccessWs]
    AS [dbo];

