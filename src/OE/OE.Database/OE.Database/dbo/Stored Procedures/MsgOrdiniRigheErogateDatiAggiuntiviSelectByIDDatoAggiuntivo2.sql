﻿
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-01-28 Nuova versione
-- Description:	Seleziona tutti dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheErogateDatiAggiuntiviSelectByIDDatoAggiuntivo2]
	  @IDRigaErogata uniqueidentifier
	, @IDDatoAggiuntivo varchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
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
		
		WHERE IDRigaErogata = @IDRigaErogata		
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
    ON OBJECT::[dbo].[MsgOrdiniRigheErogateDatiAggiuntiviSelectByIDDatoAggiuntivo2] TO [DataAccessMsg]
    AS [dbo];

