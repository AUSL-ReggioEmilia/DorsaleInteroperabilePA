




-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-11-10
-- Description:	Inserisce una nuova versione dell'ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsCodaRichiesteOutputInsert]
	  @IDTicketInserimento uniqueidentifier
	, @IDOrdineTestata uniqueidentifier
	, @Messaggio xml
	
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- INSERT
		------------------------------		
		INSERT INTO CodaRichiesteOutput
		(
			  IdTicketInserimento
			, IdOrdineTestata
			, Messaggio
		)
		VALUES
		(
			  @IDTicketInserimento
			, @IDOrdineTestata
			, @Messaggio
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
    ON OBJECT::[dbo].[WsCodaRichiesteOutputInsert] TO [DataAccessWs]
    AS [dbo];

