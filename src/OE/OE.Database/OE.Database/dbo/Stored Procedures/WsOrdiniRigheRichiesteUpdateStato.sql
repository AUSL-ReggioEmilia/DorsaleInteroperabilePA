



-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-07-20
-- Modify date: 2011-07-20
-- Description:	Aggiorna lo stato delle righe richieste
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteUpdateStato]
	  @IDTicketModifica uniqueidentifier
	, @IDsRigheRichieste varchar(max)
	, @StatoOrderEntry varchar(16)
	
AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
		--DECLARE @SQLString nvarchar(MAX) = N'UPDATE OrdiniRigheRichieste 
		--										SET DataModifica = @P_DataModifica, StatoOrderEntry = @P_StatoOrderEntry
		--										WHERE ID IN (@P_IDsRigheRichieste)'
												
		--DECLARE @ParmDefinition  nvarchar(MAX) = N'@P_DataModifica datetime, @P_StatoOrderEntry varchar(16), @P_IDsRigheRichieste varchar(max)'

		--EXECUTE sp_executesql @SQLString, @ParmDefinition, 
		--	@P_DataModifica = @DataModifica, @P_StatoOrderEntry = @StatoOrderEntry, @P_IDsRigheRichieste = @IDsRigheRichieste

		------------------------------
		-- SPLIT
		------------------------------	
		DECLARE @Value varchar(50), @Pos int
		DECLARE @tmp TABLE (ID uniqueidentifier)

		SET @IDsRigheRichieste = LTRIM(RTRIM(@IDsRigheRichieste))+ ','
		SET @Pos = CHARINDEX(',', @IDsRigheRichieste, 1)

		IF REPLACE(@IDsRigheRichieste, ',', '') <> ''
		BEGIN
			WHILE @Pos > 0
			BEGIN
				SET @Value = LTRIM(RTRIM(LEFT(@IDsRigheRichieste, @Pos - 1)))
				
				IF @Value <> ''
				BEGIN
					--INSERT INTO @tmp (ID) VALUES (CAST(@Value AS uniqueidentifier))
					INSERT INTO @tmp (ID) VALUES (@Value)
				END
				
				SET @IDsRigheRichieste = RIGHT(@IDsRigheRichieste, LEN(@IDsRigheRichieste) - @Pos)
				SET @Pos = CHARINDEX(',', @IDsRigheRichieste, 1)
			END
		END
		------------------------------
		-- UPDATE
		------------------------------				
		UPDATE OrdiniRigheRichieste
			SET
				  DataModifica = @DataModifica
				, StatoOrderEntry = @StatoOrderEntry
				, DataModificaStato = @DataModifica --DataModificaStato
		FROM
			OrdiniRigheRichieste R INNER JOIN @tmp T ON R.ID = T.ID
		
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
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteUpdateStato] TO [DataAccessWs]
    AS [dbo];

