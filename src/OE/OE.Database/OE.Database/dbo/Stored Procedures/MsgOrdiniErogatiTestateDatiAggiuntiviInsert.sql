
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-02-03
-- Modify date: 2017-11-24 Sandro: Rimosso supporto a campo XML
--
-- Description:	Inserisce un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniErogatiTestateDatiAggiuntiviInsert]
	  @IDTicketInserimento uniqueidentifier
	, @IDOrdineErogatoTestata uniqueidentifier
	, @IDDatoAggiuntivo varchar(64)
	, @Nome varchar(128)
	, @TipoDato varchar(32)
	, @TipoContenuto varchar(32)
	, @ValoreDato varchar(max)
	, @ParametroSpecifico bit
	, @Persistente bit
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
		INSERT INTO OrdiniErogatiTestateDatiAggiuntivi
		(
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, IDOrdineErogatoTestata
			, IDDatoAggiuntivo
			, Nome
			, TipoDato
			, TipoContenuto
			, ValoreDato
			, ValoreDatoVarchar
			, ParametroSpecifico
			, Persistente
		)
		VALUES
		(
			  @ID
			, @DataInserimento
			, @DataInserimento --DataModifica
			, @IDTicketInserimento
			, @IDTicketInserimento --IDTicketModifica
			, @IDOrdineErogatoTestata
			, @IDDatoAggiuntivo
			, @Nome
			, @TipoDato
			, @TipoContenuto
			, @ValoreDatoSqlVariant
			, @ValoreDatoVarchar
			, @ParametroSpecifico
			, @Persistente
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
    ON OBJECT::[dbo].[MsgOrdiniErogatiTestateDatiAggiuntiviInsert] TO [DataAccessMsg]
    AS [dbo];

