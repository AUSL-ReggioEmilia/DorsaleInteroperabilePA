





-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-04-13
-- Description:	Inserisce un messaggio di richiesta
-- =============================================
CREATE PROCEDURE [dbo].[CoreMessaggiRichiesteInsert3]
	  @IDTicketInserimento uniqueidentifier
	, @IDOrdineTestata uniqueidentifier
	, @IDSistemaRichiedente uniqueidentifier
	, @IDRichiestaRichiedente varchar(64)
	, @Messaggio xml
	, @Stato tinyint
	, @StatoOrderEntry varchar(16)
	, @Fault xml
	, @DettaglioErrore varchar(max)	
	, @ID uniqueidentifier output
	
AS
BEGIN
	--SET NOCOUNT ON;

	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
	BEGIN TRY
		
		INSERT INTO MessaggiRichieste
		(
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, IDOrdineTestata
			, IDSistemaRichiedente			
			, IDRichiestaRichiedente
			, Messaggio
			, Stato
			, StatoOrderEntry
			, Fault
			, DettaglioErrore
		)
		VALUES
		(
			  @ID
			, @DataInserimento
			, @DataInserimento --DataModifica
			, @IDTicketInserimento
			, @IDTicketInserimento --IDTicketModifica
			, @IDOrdineTestata
			, @IDSistemaRichiedente			
			, @IDRichiestaRichiedente
			, @Messaggio
			, @Stato
			, @StatoOrderEntry
			, @Fault
			, @DettaglioErrore
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
    ON OBJECT::[dbo].[CoreMessaggiRichiesteInsert3] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreMessaggiRichiesteInsert3] TO [DataAccessWs]
    AS [dbo];

