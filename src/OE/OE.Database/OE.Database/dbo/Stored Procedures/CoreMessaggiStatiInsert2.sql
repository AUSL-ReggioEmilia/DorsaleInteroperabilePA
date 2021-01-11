




-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-03-08
-- Description:	Inserisce un messaggio di stato
-- =============================================
CREATE PROCEDURE [dbo].[CoreMessaggiStatiInsert2]
	  @IDTicketInserimento uniqueidentifier
	, @IDSistemaRichiedente uniqueidentifier
	, @IDRichiestaRichiedente varchar(64)
	, @Messaggio xml
	, @Stato tinyint
	, @StatoOrderEntry varchar(16)
	, @TipoStato varchar(8)
	, @ID uniqueidentifier output
	
AS
BEGIN
	--SET NOCOUNT ON;

	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
	BEGIN TRY
	
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
			, StatoOrderEntry
			, TipoStato
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
			, @StatoOrderEntry
			, @TipoStato
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
    ON OBJECT::[dbo].[CoreMessaggiStatiInsert2] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreMessaggiStatiInsert2] TO [DataAccessWs]
    AS [dbo];

