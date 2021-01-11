

-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-05-16
-- Modify date: 2018-11-08 SANDRO: Aggirnamento campo StatoOrderEntryAggregato
--									su tutte le testate dell'ordine
-- Description:	Aggiorna lo stato d'ordine erogato
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniErogatiTestateStatusUpdate2]
	  @IDTicketModifica uniqueidentifier
	, @ID uniqueidentifier
	, @StatoOrderEntry varchar(16)
	, @DataModificaStato datetime
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataModifica datetime = GETDATE()
	DECLARE @RetCount int = 0
	
	BEGIN TRY
		------------------------------
		-- Get dello stato order entry più basso tra le righe erogate
		-- Solo se non passato
		------------------------------		
		IF @StatoOrderEntry IS NULL
			SET @StatoOrderEntry = dbo.GetMinStatoErogatoOrderEntry(@ID)

		------------------------------
		-- UPDATE
		------------------------------		
		UPDATE OrdiniErogatiTestate
		SET   DataModifica = @DataModifica
			, IDTicketModifica = @IDTicketModifica
			, StatoOrderEntry = @StatoOrderEntry
			, StatoOrderEntryAggregato = NULL
			, DataModificaStato = @DataModificaStato
		WHERE ID = @ID

		SET @RetCount = @@ROWCOUNT

		-------------------------------------------------------
		-- Update tutte le testate erogate
		-- con stato order entry aggregato tra le testate
		--
		-- VERIFICARE possibili DEAD-LOCKED
		-------------------------------------------------------
		UPDATE OrdiniErogatiTestate
			SET   StatoOrderEntryAggregato = [dbo].[GetMinStatoErogatoTestateOrderEntry]([IDOrdineTestata])
		WHERE [IDOrdineTestata] IN (
								SELECT [IDOrdineTestata] FROM OrdiniErogatiTestate WHERE [ID] = @ID
								)
		--
		-- Ret value
		--
		SELECT @RetCount AS [ROWCOUNT]
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
		--
		-- Ret 0 for ERROR
		--		
		SELECT 0 AS [ROWCOUNT]
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniErogatiTestateStatusUpdate2] TO [DataAccessMsg]
    AS [dbo];

