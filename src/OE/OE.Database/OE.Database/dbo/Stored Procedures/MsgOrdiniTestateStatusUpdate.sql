CREATE PROCEDURE [dbo].[MsgOrdiniTestateStatusUpdate]
@IDTicketModifica UNIQUEIDENTIFIER, @IDOrdineTestata UNIQUEIDENTIFIER, @SottoStatoOrderEntry VARCHAR (16)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @DataModifica datetime
		SET @DataModifica = GETDATE()
		
		-- Modify date: 2015-01-30 SANDRO: Evita l'aggiornamnto del sottostato se arriva da STATO
		--										per il problema del deadlock in lettura ordine
		IF @SottoStatoOrderEntry NOT IN ('INO_10', 'INO_20', 'INO_21')
		BEGIN
			------------------------------
			-- UPDATE
			------------------------------		
			UPDATE OrdiniTestate
				SET  DataModifica = @DataModifica
					,IDTicketModifica = @IDTicketModifica
					,SottoStatoOrderEntry = @SottoStatoOrderEntry
				WHERE 
					ID = @IDOrdineTestata
			
			SELECT @@ROWCOUNT AS [ROWCOUNT]

		END ELSE BEGIN
			-- Simula OK
			SELECT 1 AS [ROWCOUNT]
		END
			
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
    ON OBJECT::[dbo].[MsgOrdiniTestateStatusUpdate] TO [DataAccessMsg]
    AS [dbo];

