
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-01-28 Nuova versione
-- Description:	Seleziona un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniErogatiTestateDatiAggiuntiviSelect2]
	@ID uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
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
				
		WHERE ID = @ID
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniErogatiTestateDatiAggiuntiviSelect2] TO [DataAccessMsg]
    AS [dbo];

