
CREATE PROCEDURE [dbo].[MaintenanceCancella_Ticket]
  @MAX_TICKET_BATCH INT=1000
, @DEBUG BIT=0
, @LOG BIT=0
AS
BEGIN
--MODIFICHE:
-- 2016-11-25 Sandro: Primo rilascio 

	SET NOCOUNT ON
	
	SET @MAX_TICKET_BATCH = CASE WHEN @MAX_TICKET_BATCH < 1 THEN 1000
								 WHEN @MAX_TICKET_BATCH > 1000000 THEN 1000000
								ELSE @MAX_TICKET_BATCH END

	-- Contatori
	DECLARE @ERR int = 0
	DECLARE @DEL int = 1
	
	BEGIN TRY
		IF @LOG = 1
			PRINT CONVERT(varchar(40), GETDATE(), 120) + ': Inizio query cancellazione TICKET orfani'

		WHILE @ERR=0 AND @DEL > 0
		BEGIN

			DELETE TOP(@MAX_TICKET_BATCH) FROM [Tickets]
				WHERE [DataLettura] < DATEADD(DAY, -1, GETUTCDATE())
					AND NOT EXISTS(SELECT * FROM [OrdiniErogatiTestate] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [MessaggiRichieste] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [MessaggiRichieste] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [MessaggiStati] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [MessaggiStati] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniErogatiTestateDatiAggiuntivi] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniErogatiTestateDatiAggiuntivi] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniErogatiVersioni] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniTestate] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniTestate] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniRigheErogateDatiAggiuntivi] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniRigheErogateDatiAggiuntivi] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniRigheRichiesteDatiAggiuntivi] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniRigheRichiesteDatiAggiuntivi] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniTestateDatiAggiuntivi] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniTestateDatiAggiuntivi] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniRigheRichieste] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniRigheRichieste] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniVersioni] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [Prestazioni] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [Prestazioni] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniRigheErogate] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniRigheErogate] WHERE [IDTicketModifica] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniErogatiTestate] WHERE [IDTicketInserimento] = [Tickets].[ID])
					AND NOT EXISTS(SELECT * FROM [OrdiniErogatiTestate] WHERE [IDTicketModifica] = [Tickets].[ID])
			
			SELECT @ERR = @@ERROR, @DEL = @@ROWCOUNT

			IF @DEBUG = 1
				PRINT CONVERT(varchar(40), GETDATE(), 120) + ': --- Cancellati ' + CONVERT(varchar(10), @DEL) + ' TICKET orfani'
		END

		IF @LOG = 1
			PRINT CONVERT(varchar(40), GETDATE(), 120) + ': Completata cancellazione TICKET orfani'

	END TRY
	BEGIN CATCH
	
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END