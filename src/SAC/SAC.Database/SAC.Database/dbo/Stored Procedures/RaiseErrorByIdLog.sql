



CREATE PROCEDURE [dbo].[RaiseErrorByIdLog] 
(
	@ErrorLogID [int] = 0 
)
AS
BEGIN
/********************************************************************************
	DESCRIZIONE
*********************************************************************************
	La SP serve a restituire un messaggio comprensibile all'utente
	
*********************************************************************************
	VERSIONI
*********************************************************************************
	Versione	Data		Autore				Descrizione
	1.0			2013-01-28	Alessandro Nostini	Creazione SP 
	1.1			2014-04-07	Ettore Garulli		Aggiunto gestione errore 2627 
												'Violazione chiave primaria'
********************************************************************************/
	SET NOCOUNT ON;
	
	IF @ErrorLogID = 0
		RETURN 0

	DECLARE @ErrorNumber [int]
	DECLARE @ErrorSeverity [int]
	DECLARE @ErrorState [int]
	DECLARE @ErrorProcedure [nvarchar](126)
	DECLARE @ErrorLine [int]
	DECLARE @ErrorMessage [nvarchar](4000)
	
	SELECT	@ErrorNumber = [ErrorNumber], 
			@ErrorSeverity = [ErrorSeverity], 
			@ErrorState = [ErrorState], 
			@ErrorProcedure = ISNULL([ErrorProcedure], '-'), 
			@ErrorLine = [ErrorLine], 
			@ErrorMessage = [ErrorMessage]
	FROM [dbo].[ErrorLog] 
	WHERE [ErrorLogID] = @ErrorLogID;
	
	-- Controllo il messaggio se vuoto
	IF @ErrorMessage IS NULL
		RETURN 0
	--
	-- Modifica Ettore: intercetto gli errori noti per creare un messaggio custom
	--					altrimenti visualizzao un messagio di errore con il numero di riga
	--
	IF @ErrorNumber = 50000 --Eventuali messaggi di errore scritti nelle SP
	BEGIN
		RAISERROR (@ErrorMessage, 16 , 1)
		RETURN	--fondamentale altrimenti entra anche nell'ELSE finale
	END
	IF @ErrorNumber = 547 --The DELETE/UPDATE statement conflicted with the REFERENCE constraint "FK_XXXX". 
	BEGIN
		RAISERROR ('Si è verificato un errore di integrità referenziale (Il record è in uso in altre tabelle).', 16 , 1)
		RETURN	--fondamentale altrimenti entra anche nell'ELSE finale
	END
	IF @ErrorNumber = 2601 --Cannot insert duplicate key row in object '<TABELLA>' with unique index '<IX_XXXX>'. The duplicate key value is (<XXXXXXXX>).
	BEGIN
		RAISERROR ('Si è verificato un errore di chiave duplicata.', 16 , 1)
		RETURN	--fondamentale altrimenti entra anche nell'ELSE finale
	END
	IF @ErrorNumber = 2627 --Violation of PRIMARY KEY constraint 'PK_chiave'. Cannot insert duplicate key in object '<TABELLA>'. The duplicate key value is (<XXXXXXXX>). 
	BEGIN
		RAISERROR ('Si è verificato un errore di violazione di chiave primaria.', 16 , 1)
		RETURN	--fondamentale altrimenti entra anche nell'ELSE finale
	END
	IF @ErrorNumber = 1205 --DEADLOCK
	BEGIN 
		RAISERROR ('Si è verificato un errore di deadlock. Rieseguire la transazione.', 16 , 1)
		RETURN	--fondamentale altrimenti entra anche nell'ELSE finale
	END
	ELSE
	BEGIN
		RAISERROR ('ErrorLogId=%d. Contattare l''amministratore.', 16, 1, @ErrorLogID)
		RETURN	
	END
	/*
	RAISERROR ('Msg %d, Level %d, State %d, Procedure %s, Line %d: %s.'
				   , @ErrorSeverity , @ErrorState
				   , @ErrorNumber -- 1 parametro
				   , @ErrorSeverity -- 2 parametro
				   , @ErrorState -- 3 parametro
				   , @ErrorProcedure -- 4 parametro
				   , @ErrorLine -- 5 parametro
				   , @ErrorMessage); -- 6 parametro
	*/
END;



