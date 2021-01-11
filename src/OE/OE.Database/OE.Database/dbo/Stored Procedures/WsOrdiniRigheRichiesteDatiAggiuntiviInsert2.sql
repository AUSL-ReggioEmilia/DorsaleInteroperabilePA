

-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-03-01
-- Modify date: 2017-11-24 Sandro: Rimosso supporto a campo XML
--									Aggiunti parametro @ValoreDatoXml e @ParametroSpecifico
--										per gestire i dati acessori
--
-- Description:	Inserisce un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteDatiAggiuntiviInsert2]
	  @IDTicketInserimento uniqueidentifier
	, @IDRigaRichiesta uniqueidentifier
	, @IDDatoAggiuntivo varchar(64)
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
		
	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
	BEGIN TRY
		------------------------------
		-- INSERT
		------------------------------		
		INSERT INTO OrdiniRigheRichiesteDatiAggiuntivi
		(
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, IDRigaRichiesta
			, IDDatoAggiuntivo
			, Nome
			, TipoDato
			, TipoContenuto
			, ValoreDato
			, ValoreDatoVarchar
			, Persistente
			, ValoreDatoXml
			, ParametroSpecifico
		)
		VALUES
		(
			  @ID
			, @DataInserimento
			, @DataInserimento --DataModifica
			, @IDTicketInserimento
			, @IDTicketInserimento --IDTicketModifica
			, @IDRigaRichiesta
			, @IDDatoAggiuntivo
			, @Nome
			, @TipoDato
			, @TipoContenuto
			, @ValoreDatoSqlVariant
			, @ValoreDatoVarchar
			, @Persistente
			, @ValoreDatoXml
			, @ParametroSpecifico
		)
						
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
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteDatiAggiuntiviInsert2] TO [DataAccessWs]
    AS [dbo];

