
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-01-28 Nuova versione
-- Description:	Seleziona un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniErogatiTestateDatiAggiuntiviSelectByIDDatoAggiuntivo2]
	  @IDOrdineErogatoTestata uniqueidentifier
	, @IDDatoAggiuntivo varchar(64)
	, @Persistente bit = 1
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
		
		WHERE	IDOrdineErogatoTestata = @IDOrdineErogatoTestata
			AND IDDatoAggiuntivo = @IDDatoAggiuntivo
			AND Persistente = @Persistente
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniErogatiTestateDatiAggiuntiviSelectByIDDatoAggiuntivo2] TO [DataAccessMsg]
    AS [dbo];

