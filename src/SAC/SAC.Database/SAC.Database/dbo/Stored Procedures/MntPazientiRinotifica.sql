
-- =============================================
-- Author:		?
-- Create date: ?
-- Description:	
-- Modify date: 2018-09-17 - ETTORE: Gestito tutti i tipi di rinotifica (mancavano i casi Tipo=7,8,9)
-- =============================================
CREATE PROCEDURE [dbo].[MntPazientiRinotifica](
	 @DateFrom AS DATETIME = NULL
	,@DateTo AS DATETIME = NULL
	,@NoFusioni AS BIT = 1
	,@Simulazione AS BIT = 1
)
AS
BEGIN
/*
	Tipo:
		0=Msg
		1=UI
		2=WS
		3=Batch-merge
		4=Msg-notifica-merge
		5=UI-notifica-merge
		6=WS-merge
		7=Aggiornamento Padre per notifica DataDecesso
		8=Modifica consenso
		9=Modifica esenzione
*/
	SET NOCOUNT ON;	
	
	IF @DateFrom IS NULL
		RAISERROR('Il parametro @DateFrom non può essere NULL!', 16, 1)

	IF @NoFusioni = 0 AND NOT @DateTo IS NULL
		RAISERROR('Se @NoFusioni = 0 il parametro @DateTo deve essere NULL!', 16, 1)

	IF @DateTo IS NULL
		SET @DateTo = GETDATE()

	IF @Simulazione = 1
		PRINT 'Modalità simulazione dalla data ' + CONVERT(VARCHAR, @DateFrom, 120)
	
	DECLARE TheCursor CURSOR STATIC READ_ONLY FOR 	
		--
		-- Recupero gli Id
		--
		SELECT [IdPaziente]
			  ,[Data]
			  ,[Tipo]
		FROM [dbo].[PazientiNotifiche]
		WHERE [Data] BETWEEN @DateFrom AND @DateTo
			AND (
				(@NoFusioni = 1 AND [Tipo] IN (1,2,7,8,9)) --solo modifiche anagrafiche (UI e WS) + aggiornamenti a seguito di altre operazioni
				OR
				(@NoFusioni = 0 AND [Tipo] IN (1,2,3,4,5,6,7,8,9)) --tutto tranne Tipo=0 che tanto non verrebbe notificato
				)
		
		UNION
		SELECT [IdPaziente]
			  ,[Data]
			  ,[Tipo]
		FROM [dbo].[PazientiNotifiche_Storico]
		WHERE [Data] BETWEEN @DateFrom AND @DateTo
			AND (
				(@NoFusioni = 1 AND [Tipo] IN (1,2,7,8,9)) --solo modifiche anagrafiche (UI e WS) + aggiornamenti a seguito di altre operazioni
				OR
				(@NoFusioni = 0 AND [Tipo] IN (1,2,3,4,5,6,7,8,9)) --tutto tranne Tipo=0 che tanto non verrebbe notificato
				)
		ORDER BY Data
	
	--
	-- Apro il cursore
	--
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @Data DATETIME
	DECLARE @Tipo INT
	DECLARE @Numero INT = 0

	DECLARE @Utente varchar(64)
	SET @Utente = 'MntPazientiRinotifica' --USER_NAME()

	OPEN TheCursor
	FETCH NEXT FROM TheCursor INTO @IdPaziente, @Data, @Tipo
	WHILE @@FETCH_STATUS = 0 
		BEGIN
			IF @Simulazione = 0
				BEGIN
					--
					-- Inserimento del record di notifica
					--
					EXEC PazientiNotificheAdd @IdPaziente, @Tipo, @Utente
					
					PRINT '-- Notifico paziente ID = ' + CONVERT(VARCHAR(40), @IdPaziente)
							+ ' del ' + CONVERT(VARCHAR, @Data, 120)
							+ ' Tipo ' + CONVERT(VARCHAR, @Tipo)
				END
			ELSE
				BEGIN
					--
					-- Simulazione
					--
					PRINT '-- Simulazione paziente ID = ' + CONVERT(VARCHAR(40), @IdPaziente)
							+ ' del ' + CONVERT(VARCHAR, @Data, 120)
							+ ' Tipo ' + CONVERT(VARCHAR, @Tipo)
				END
				
			SET @Numero = @Numero + 1
			--
			-- Avanzo il cursore
			-- 			
			FETCH NEXT FROM TheCursor INTO @IdPaziente, @Data, @Tipo
		END
	--
	-- Chiudo il cursore
	--
	CLOSE TheCursor
	DEALLOCATE TheCursor
	
	PRINT 'Rinotificati ' + CONVERT(VARCHAR, @Numero) + ' pazienti!'
END
