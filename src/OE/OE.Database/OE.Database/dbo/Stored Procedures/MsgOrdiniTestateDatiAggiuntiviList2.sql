
-- =============================================
-- Author: Alessandro Nostini
-- Create date: 2014-01-27 Nuova versione senza dati inserimento modifica TS
-- Modify date: 2014-01-27
-- Description:	Seleziona i dato aggiuntivo di una riga
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniTestateDatiAggiuntiviList2]
	@IDOrdineTestata uniqueidentifier
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
		
		WHERE IDOrdineTestata = @IDOrdineTestata
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniTestateDatiAggiuntiviList2] TO [DataAccessMsg]
    AS [dbo];

