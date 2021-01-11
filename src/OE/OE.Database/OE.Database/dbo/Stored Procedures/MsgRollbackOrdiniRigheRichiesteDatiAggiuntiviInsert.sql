





-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-05-12
-- Modify date: 2011-05-12
-- Description:	Rollback di un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[MsgRollbackOrdiniRigheRichiesteDatiAggiuntiviInsert]
	  @ID uniqueidentifier
	, @DataInserimento datetime
	, @DataModifica datetime
	, @IDTicketInserimento uniqueidentifier
	, @IDTicketModifica uniqueidentifier
	, @IDRigaRichiesta uniqueidentifier
	, @IDDatoAggiuntivo varchar(64)
	, @Nome varchar(128)
	, @TipoDato varchar(32)
	, @TipoContenuto varchar(32)
	, @ValoreDato sql_variant
	, @ValoreDatoVarchar varchar(max)
	, @ValoreDatoXml xml
	, @ParametroSpecifico bit
	, @Persistente bit
	
AS
BEGIN
	--SET NOCOUNT ON;

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
			, ValoreDatoXml
			, ParametroSpecifico
			, Persistente
		)
		VALUES
		(
			  @ID
			, @DataInserimento
			, @DataModifica
			, @IDTicketInserimento
			, @IDTicketModifica
			, @IDRigaRichiesta
			, @IDDatoAggiuntivo
			, @Nome
			, @TipoDato
			, @TipoContenuto
			, @ValoreDato
			, @ValoreDatoVarchar
			, @ValoreDatoXml
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
    ON OBJECT::[dbo].[MsgRollbackOrdiniRigheRichiesteDatiAggiuntiviInsert] TO [DataAccessMsg]
    AS [dbo];

