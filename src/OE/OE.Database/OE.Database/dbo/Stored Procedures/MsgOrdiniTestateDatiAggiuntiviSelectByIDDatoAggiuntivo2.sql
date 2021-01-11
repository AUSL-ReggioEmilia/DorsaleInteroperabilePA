-- =============================================
-- Author: Alessandro Nostini
-- Create date: 2014-01-27 Nuova versione senza dati inserimento modifica TS
-- Modify date: 2014-01-27
-- Description:	Seleziona un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniTestateDatiAggiuntiviSelectByIDDatoAggiuntivo2]
	  @IDOrdineTestata uniqueidentifier
	, @IDDatoAggiuntivo varchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
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
		
		WHERE	IDOrdineTestata = @IDOrdineTestata
			AND IDDatoAggiuntivo = @IDDatoAggiuntivo
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniTestateDatiAggiuntiviSelectByIDDatoAggiuntivo2] TO [DataAccessMsg]
    AS [dbo];

