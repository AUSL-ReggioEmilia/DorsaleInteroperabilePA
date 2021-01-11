
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-01-17
-- Description:	Storicizza il db order entry
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceCancella_Ordini]
 @DATE_FROM DATE
,@DATE_TO DATE
,@MAX_ORDERS_HISTORY INT=1000
,@DEBUG BIT=1
AS
BEGIN
--MODIFICHE:
-- 2013-01-17 Sandro: Primo rilascio 

	SET NOCOUNT ON
	
	DECLARE @TOP as int
	SET @TOP = CASE WHEN @MAX_ORDERS_HISTORY < 1 THEN 2147483647
									ELSE @MAX_ORDERS_HISTORY END

	-- Contatori
	DECLARE @TOT_ORDERS as int = 0
	DECLARE @TOT_HISTORY_ORDERS as int = 0
	
	BEGIN TRY
		PRINT 'Inizio query selezione record da storicizzare ' + CONVERT(varchar(40), GETDATE(), 120)

	
		DECLARE @IdOrdine uniqueidentifier, @DataModifica datetime2(0)
		DECLARE mainCursor CURSOR STATIC READ_ONLY FOR
	
		-- Riferimento agli ordini che sono da storicizzare
		SELECT TOP (@TOP) ID, DataModifica
			FROM OrdiniTestate WITH(NOLOCK)
			WHERE DataInserimento BETWEEN @DATE_FROM AND @DATE_TO
			ORDER BY DataModifica
		
		OPEN mainCursor
		FETCH NEXT FROM mainCursor INTO @IdOrdine, @DataModifica
		
		PRINT 'Inizio loop sui record da storicizzare ' + CONVERT(varchar(40), GETDATE(), 120)
		PRINT ''
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			IF @DEBUG = 1
			BEGIN
				PRINT '[Debug] Storicizzazione dell''ordine ' + CAST(@IdOrdine as varchar(max)) + ' del ' + CONVERT(varchar(40), @DataModifica, 120)
				GOTO FetchNext
			END
		
			BEGIN TRY
				
				-- Inizio la transazione
				BEGIN TRANSACTION
				
				-- Delete MessaggiStati
				DELETE FROM MessaggiStati 
				FROM MessaggiStati M INNER JOIN OrdiniErogatiTestate O ON M.IDOrdineErogatoTestata = O.ID
				WHERE O.IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniErogatiVersioni
				DELETE FROM OrdiniErogatiVersioni 
				FROM OrdiniErogatiVersioni V
					INNER JOIN OrdiniErogatiTestate O ON V.IDOrdineErogatoTestata = O.ID
				WHERE O.IDOrdineTestata = @IdOrdine
																	
				-- Delete OrdiniVersioni
				DELETE FROM OrdiniVersioni 
				WHERE IDOrdineTestata = @IdOrdine
				
				-- Delete MessaggiRichieste
				DELETE FROM MessaggiRichieste 
				WHERE IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniRigheErogateDatiAggiuntivi
				DELETE FROM OrdiniRigheErogateDatiAggiuntivi
				FROM OrdiniRigheErogateDatiAggiuntivi DA INNER JOIN OrdiniRigheErogate R ON DA.IDRigaErogata = R.ID INNER JOIN OrdiniErogatiTestate O ON R.IDOrdineErogatoTestata = O.ID
				WHERE O.IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniRigheErogate
				DELETE FROM OrdiniRigheErogate
				FROM OrdiniRigheErogate R INNER JOIN OrdiniErogatiTestate O ON R.IDOrdineErogatoTestata = O.ID
				WHERE O.IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniErogatiVersioni
				DELETE FROM OrdiniErogatiVersioni
				FROM OrdiniErogatiVersioni OV INNER JOIN OrdiniErogatiTestate O ON OV.IDOrdineErogatoTestata = O.ID
				WHERE O.IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniErogatiTestateDatiAggiuntivi
				DELETE FROM OrdiniErogatiTestateDatiAggiuntivi
				FROM OrdiniErogatiTestateDatiAggiuntivi DA INNER JOIN OrdiniErogatiTestate O ON DA.IDOrdineErogatoTestata = O.ID
				WHERE O.IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniErogatiTestate
				DELETE FROM OrdiniErogatiTestate WHERE IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniRigheRichiesteDatiAggiuntivi
				DELETE FROM OrdiniRigheRichiesteDatiAggiuntivi
				FROM OrdiniRigheRichiesteDatiAggiuntivi DA INNER JOIN OrdiniRigheRichieste R ON DA.IDRigaRichiesta = R.ID
				WHERE R.IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniRigheRichieste
				DELETE FROM OrdiniRigheRichieste WHERE IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniVersioni
				DELETE FROM OrdiniVersioni WHERE IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniTestateDatiAggiuntivi
				DELETE FROM OrdiniTestateDatiAggiuntivi WHERE IDOrdineTestata = @IdOrdine
				
				-- Delete OrdiniTestate
				DELETE FROM OrdiniTestate WHERE ID = @IdOrdine
							
								
				PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Cancellazione dell''ordine ' + CAST(@IdOrdine as varchar(max))
						+ ' del ' + CONVERT(varchar(40), @DataModifica, 120)
						+ ' completata con successo.'
				COMMIT
				
				SET @TOT_HISTORY_ORDERS = @TOT_HISTORY_ORDERS + 1
			END TRY
			BEGIN CATCH
				
				ROLLBACK
				
				PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Storicizzazione dell''ordine ' + CAST(@IdOrdine as varchar(max)) + ' fallita!'
				
				DECLARE @reason as varchar(max) = dbo.GetException()
				PRINT CHAR(9) + 'Errore: ' + @reason
			END CATCH
FetchNext:
			-- Altro record
			SET @TOT_ORDERS = @TOT_ORDERS + 1
			
			FETCH NEXT FROM mainCursor INTO @IdOrdine, @DataModifica
		END
		CLOSE mainCursor
		DEALLOCATE mainCursor
		
		PRINT ''
		PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Storicizzazione completata. Totale ordini storicizzati ' + CAST(@TOT_HISTORY_ORDERS as varchar(max)) + ' su ' + CAST(@TOT_ORDERS as varchar(max))
	END TRY
	BEGIN CATCH
	
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

