
CREATE PROCEDURE [dbo].[MntPazientiRinotificaFusioni](
	 @DateFrom AS DATETIME = NULL
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
*/
	SET NOCOUNT ON;	
	
	IF @DateFrom IS NULL
		RAISERROR('Il parametro @DateFrom non può essere NULL!', 16, 1)

	IF @Simulazione = 1
		PRINT 'Modalità simulazione dalla data ' + CONVERT(VARCHAR, @DateFrom, 120)
	
	DECLARE @DateTo DATETIME = DATEADD(MINUTE, -1, GETDATE())
	
	DECLARE TheCursor CURSOR STATIC READ_ONLY FOR 	
		--
		-- Recupero gli Id
		--
		SELECT [IdPaziente]
			  ,[Data]
			  ,[Tipo]
		FROM [dbo].[PazientiNotifiche]
		WHERE [Data] BETWEEN @DateFrom AND @DateTo
			AND [Tipo] IN (3,4,5,6)
		UNION
		SELECT [IdPaziente]
			  ,[Data]
			  ,[Tipo]
		FROM [dbo].[PazientiNotifiche_Storico]
		WHERE [Data] BETWEEN @DateFrom AND @DateTo
			AND [Tipo] IN (3,4,5,6)
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
