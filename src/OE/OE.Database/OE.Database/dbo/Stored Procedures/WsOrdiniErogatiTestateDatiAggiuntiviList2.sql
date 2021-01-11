
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2011-10-26
-- Modify date: 2014-02-14 Nuova versione senz data sis e ticket
-- Modify date: 2017-10-12 Ordina i dati per inserimento usando il TS
--							Serve per mantenere inalterata la sequenza dei nodi xml
-- Description:	Seleziona un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniErogatiTestateDatiAggiuntiviList2]
	  @IDOrdineErogatoTestata uniqueidentifier
	, @IDDatoAggiuntivo varchar(64)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT  ID
		  , IDOrdineErogatoTestata
		  , IDDatoAggiuntivo
		  , Nome
		  , TipoDato
		  , TipoContenuto
		  , ValoreDato
		  , ValoreDatoVarchar
		  , ValoreDatoXml
		  , ParametroSpecifico
		  , Persistente
	FROM OrdiniErogatiTestateDatiAggiuntivi
	WHERE IDOrdineErogatoTestata = @IDOrdineErogatoTestata
		AND (@IDDatoAggiuntivo IS NULL OR IDDatoAggiuntivo = @IDDatoAggiuntivo)
	ORDER BY TS
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniErogatiTestateDatiAggiuntiviList2] TO [DataAccessWs]
    AS [dbo];

