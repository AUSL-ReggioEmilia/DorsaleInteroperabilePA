









-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-15
-- Modify date: 2011-03-18
-- Description:	Aggiorna una riga erogata d'ordine
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheErogateUpdate]
	  @IDTicketModifica uniqueidentifier
	, @ID uniqueidentifier
	, @StatoOrderEntry varchar(16)
	, @DataModificaStato datetime
	, @IDPrestazione uniqueidentifier
	, @IDRigaErogante varchar(64)
	, @StatoErogante xml
	, @Data datetime
	, @Operatore xml
	, @Consensi xml
	
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
	
		DECLARE @DataModifica datetime
		SET @DataModifica = GETDATE()
	
		------------------------------
		-- UPDATE
		------------------------------		
		UPDATE OrdiniRigheErogate
			SET 
				  DataModifica = @DataModifica
				, IDTicketModifica = @IDTicketModifica
				, StatoOrderEntry = @StatoOrderEntry
				, DataModificaStato = @DataModificaStato
				, IDPrestazione = @IDPrestazione
				, IDRigaErogante =  @IDRigaErogante
				, StatoErogante = @StatoErogante
				, Data = @Data
				, Operatore = @Operatore
				, Consensi = @Consensi
				
			WHERE 
				ID  = @ID
				
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
    ON OBJECT::[dbo].[MsgOrdiniRigheErogateUpdate] TO [DataAccessMsg]
    AS [dbo];

