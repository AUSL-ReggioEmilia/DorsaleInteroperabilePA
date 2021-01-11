-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2011-10-26
-- Create date: 2014-02-14 Nuova varsione senza Data sys e ticket
-- Modify date: 2017-10-12 Ordina i dati per inserimento usando il TS
--							Serve per mantenere inalterata la sequenza dei nodi xml

-- Description:	Seleziona un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteDatiAggiuntiviList2]
	  @IDRigaRichiesta uniqueidentifier
	, @IDDatoAggiuntivo varchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  ID
		  , IDRigaRichiesta
		  , IDDatoAggiuntivo
		  , Nome
		  , TipoDato
		  , TipoContenuto
		  , ValoreDato
		  , ValoreDatoVarchar
		  , ValoreDatoXml
		  , ParametroSpecifico
		  , Persistente
	FROM OrdiniRigheRichiesteDatiAggiuntivi
	WHERE IDRigaRichiesta = @IDRigaRichiesta
		AND (@IDDatoAggiuntivo IS NULL OR IDDatoAggiuntivo = @IDDatoAggiuntivo)
	ORDER BY TS
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteDatiAggiuntiviList2] TO [DataAccessWs]
    AS [dbo];

