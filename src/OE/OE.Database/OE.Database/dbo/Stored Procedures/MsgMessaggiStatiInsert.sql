


-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-07
-- Modify date: 2011-03-10
-- Description:	Inserisce un messaggio di stato
-- =============================================
CREATE PROCEDURE [dbo].[MsgMessaggiStatiInsert]
	  @IDTicketInserimento uniqueidentifier
	, @IDSistemaRichiedente uniqueidentifier
	, @IDRichiestaRichiedente varchar(64)
	, @Messaggio xml
	, @Stato tinyint
	, @ID uniqueidentifier output
	
AS
BEGIN
	--SET NOCOUNT ON;

	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
	BEGIN TRY
		------------------------------
		-- INSERT
		------------------------------		
		INSERT INTO MessaggiStati
		(
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, IDRichiestaRichiedente
			, Messaggio
			, Stato
			, IDSistemaRichiedente
		)
		VALUES
		(
			  @ID
			, @DataInserimento
			, @DataInserimento --DataModifica
			, @IDTicketInserimento
			, @IDTicketInserimento --IDTicketModifica
			, @IDRichiestaRichiedente
			, @Messaggio
			, @Stato
			, @IDSistemaRichiedente
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
    ON OBJECT::[dbo].[MsgMessaggiStatiInsert] TO [DataAccessMsg]
    AS [dbo];

