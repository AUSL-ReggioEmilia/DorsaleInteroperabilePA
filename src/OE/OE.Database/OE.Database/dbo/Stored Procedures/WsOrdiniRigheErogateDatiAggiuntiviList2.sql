--=============================================
-- Author:		Alessandro Nostini
-- Create date: 2011-10-26
-- Create date: 2014-02-14
-- Modify date: 2017-10-12 Ordina i dati per inserimento usando il TS
--							Serve per mantenere inalterata la sequenza dei nodi xml
-- Description:	Seleziona un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheErogateDatiAggiuntiviList2]
	  @IDRigaErogata uniqueidentifier
	, @IDDatoAggiuntivo varchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  ID
		  , IDRigaErogata
		  , IDDatoAggiuntivo
		  , Nome
		  , TipoDato
		  , TipoContenuto
		  , ValoreDato
		  , ValoreDatoVarchar
		  , ValoreDatoXml
		  , ParametroSpecifico
		  , Persistente
	FROM OrdiniRigheErogateDatiAggiuntivi
	WHERE	IDRigaErogata = @IDRigaErogata
		AND (@IDDatoAggiuntivo IS NULL OR IDDatoAggiuntivo = @IDDatoAggiuntivo)
	ORDER BY TS
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniRigheErogateDatiAggiuntiviList2] TO [DataAccessWs]
    AS [dbo];

