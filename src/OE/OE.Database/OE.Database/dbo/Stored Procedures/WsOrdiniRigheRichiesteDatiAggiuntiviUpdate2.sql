﻿

-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-03-01
-- Modify date: 2017-11-24 Sandro: Rimosso supporto a campo XML
--									Aggiunti parametro @ValoreDatoXml e @ParametroSpecifico
--										per gestire i dati acessori
--
-- Description:	Aggiorna un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteDatiAggiuntiviUpdate2]
	  @ID uniqueidentifier
	, @IDTicketModifica uniqueidentifier
	, @Nome varchar(128)
	, @TipoDato varchar(32)
	, @TipoContenuto varchar(32)
	, @ValoreDato varchar(max)
	, @Persistente bit
	, @ValoreDatoXml xml = NULL
	, @ParametroSpecifico bit = 0
AS
BEGIN
	SET NOCOUNT ON;

	------------------------------
	-- CONVERT
	------------------------------	
	DECLARE @ValoreDatoSqlVariant sql_variant = null
	DECLARE @ValoreDatoVarchar varchar(max) = null

	EXEC dbo.CoreDatiAggiuntiviConvert2 @TipoDato, @ValoreDato, @ValoreDatoSqlVariant output, @ValoreDatoVarchar output

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
		------------------------------
		-- UPDATE
		------------------------------		
		UPDATE OrdiniRigheRichiesteDatiAggiuntivi
			SET
				  DataModifica = @DataModifica
				, IDTicketModifica = @IDTicketModifica
				, Nome = @Nome
				, TipoDato = @TipoDato
				, TipoContenuto = @TipoContenuto
				, ValoreDato = @ValoreDatoSqlVariant
				, ValoreDatoVarchar = @ValoreDatoVarchar
				, Persistente = @Persistente
				, ValoreDatoXml = @ValoreDatoXml
				, ParametroSpecifico = @ParametroSpecifico		
			WHERE 
				ID = @ID
					
		SELECT @@ROWCOUNT AS [ROWCOUNT]
								
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
		
		SELECT @@ROWCOUNT AS [ROWCOUNT]
	END CATCH
	
END

































GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteDatiAggiuntiviUpdate2] TO [DataAccessWs]
    AS [dbo];

