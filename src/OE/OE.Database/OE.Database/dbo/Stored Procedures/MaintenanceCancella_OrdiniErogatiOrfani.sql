
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-03-15
-- Description:	Storicizza il db order entry
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceCancella_OrdiniErogatiOrfani]
 @NR_GG_NO_HISTORY INT=7
,@BATCH_SIZE INT=1000
,@DEBUG BIT=1
AS
BEGIN
--MODIFICHE:
-- 2013-03-15 Sandro: Primo rilascio 
-- 2020-04-22 Sandro: Review 

	SET NOCOUNT ON
	
	SET @NR_GG_NO_HISTORY = CASE WHEN @NR_GG_NO_HISTORY < 1 THEN 1
									ELSE @NR_GG_NO_HISTORY END
	DECLARE @TOP as int
	SET @TOP = CASE WHEN @BATCH_SIZE < 1 THEN 2147483647
									ELSE @BATCH_SIZE END

	-- Contatori
	DECLARE @TOT_ORDERS as int = 0
	DECLARE @TOT_HISTORY_ORDERS as int = 0
	
	BEGIN TRY
		PRINT 'Inizio query selezione record da cancellare ' + CONVERT(varchar(40), GETDATE(), 120)

	
		DECLARE @IdOrdiniErogatiTestate uniqueidentifier, @DataModifica datetime2(0)
		DECLARE mainCursor CURSOR STATIC READ_ONLY FOR
	
		-- Riferimento agli OrdiniErogateTestate che sono da cancellare
		--
		SELECT TOP (@TOP) ID, DataModifica
			FROM OrdiniErogatiTestate WITH(NOLOCK)
			WHERE DataInserimento <= DATEADD(dd, -@NR_GG_NO_HISTORY, GETDATE())
				AND IDOrdineTestata IS NULL
			ORDER BY DataModifica
		
		OPEN mainCursor
		FETCH NEXT FROM mainCursor INTO @IdOrdiniErogatiTestate, @DataModifica
		
		PRINT 'Inizio loop sui record da cancellare ' + CONVERT(varchar(40), GETDATE(), 120)
		PRINT ''
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			IF @DEBUG = 1
			BEGIN
				PRINT '[Debug] Cancelazione dell''ordine erogato' + CAST(@IdOrdiniErogatiTestate as varchar(max)) + ' del ' + CONVERT(varchar(40), @DataModifica, 120)
				GOTO FetchNext
			END
		
			BEGIN TRY
				
				-- Inizio la transazione
				BEGIN TRANSACTION
							
				-- Delete MessaggiStati
				DELETE FROM MessaggiStati 
				FROM MessaggiStati M INNER JOIN OrdiniErogatiTestate O ON M.IDOrdineErogatoTestata = O.ID
				WHERE O.ID = @IdOrdiniErogatiTestate
				
				-- Delete OrdiniErogatiVersioni
				DELETE FROM OrdiniErogatiVersioni 
				FROM OrdiniErogatiVersioni V
					INNER JOIN OrdiniErogatiTestate O ON V.IDOrdineErogatoTestata = O.ID
				WHERE O.ID = @IdOrdiniErogatiTestate
				
				-- Delete OrdiniRigheErogateDatiAggiuntivi
				DELETE FROM OrdiniRigheErogateDatiAggiuntivi
				FROM OrdiniRigheErogateDatiAggiuntivi DA INNER JOIN OrdiniRigheErogate R ON DA.IDRigaErogata = R.ID INNER JOIN OrdiniErogatiTestate O ON R.IDOrdineErogatoTestata = O.ID
				WHERE O.ID = @IdOrdiniErogatiTestate
				
				-- Delete OrdiniRigheErogate
				DELETE FROM OrdiniRigheErogate
				FROM OrdiniRigheErogate R INNER JOIN OrdiniErogatiTestate O ON R.IDOrdineErogatoTestata = O.ID
				WHERE O.ID = @IdOrdiniErogatiTestate
				
				-- Delete OrdiniErogatiTestateDatiAggiuntivi
				DELETE FROM OrdiniErogatiTestateDatiAggiuntivi
				FROM OrdiniErogatiTestateDatiAggiuntivi DA INNER JOIN OrdiniErogatiTestate O ON DA.IDOrdineErogatoTestata = O.ID
				WHERE O.ID = @IdOrdiniErogatiTestate
				
				-- Delete OrdiniErogatiTestate
				DELETE FROM OrdiniErogatiTestate WHERE ID = @IdOrdiniErogatiTestate
								
				PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Cancellazione dell''ordine ' + CAST(@IdOrdiniErogatiTestate as varchar(max))
						+ ' del ' + CONVERT(varchar(40), @DataModifica, 120)
						+ ' completata con successo.'
				COMMIT
				
				SET @TOT_HISTORY_ORDERS = @TOT_HISTORY_ORDERS + 1
			END TRY
			BEGIN CATCH
				
				ROLLBACK
				
				PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Cancellazione dell''ordine ' + CAST(@IdOrdiniErogatiTestate as varchar(max)) + ' fallita!'
				
				DECLARE @reason as varchar(max) = dbo.GetException()
				PRINT CHAR(9) + 'Errore: ' + @reason
			END CATCH
FetchNext:
			-- Altro record
			SET @TOT_ORDERS = @TOT_ORDERS + 1
			
			FETCH NEXT FROM mainCursor INTO @IdOrdiniErogatiTestate, @DataModifica
		END
		CLOSE mainCursor
		DEALLOCATE mainCursor
		
		PRINT ''
		PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Cancellazione completata. Totale ordini storicizzati ' + CAST(@TOT_HISTORY_ORDERS as varchar(max)) + ' su ' + CAST(@TOT_ORDERS as varchar(max))
	END TRY
	BEGIN CATCH
	
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

