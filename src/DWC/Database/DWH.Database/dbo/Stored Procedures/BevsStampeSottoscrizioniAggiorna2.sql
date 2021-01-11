


CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniAggiorna2]
(
	@Id UNIQUEIDENTIFIER
	, @DataFine AS DATETIME
	, @IdTipoReferti AS INTEGER
	, @ServerDiStampa AS VARCHAR(64) 
	, @Stampante AS VARCHAR(64) 
	, @IdStato AS INTEGER
	, @Nome AS VARCHAR(128)	
	, @Descrizione AS VARCHAR(1024)
	, @Ts AS TIMESTAMP
	, @StampaConfidenziali AS BIT
	, @StampaOscurati AS BIT
	, @NumeroCopie AS TINYINT = 1
) 
AS
BEGIN
/*
	CREATA DA ETTORE 2015-07-03: aggiunto i nuovi campi StampaConfidenziali e StampaOscurati
	MODIFICATA DA ETTORE 2017-01-09: aggiunto nuovo campo NumeroCopie
*/
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY
		SET @ServerDiStampa = '\\' + REPLACE(@ServerDiStampa , '\', '')

		-- Memorizzo lo stato corrente
		DECLARE @IdStato_Old AS INTEGER
		SELECT @IdStato_Old FROM StampeSottoscrizioni WHERE Id = @Id

		-- Se si attiva una sottoscrizione
		IF (NOT @IdStato_Old IS NULL) AND (@IdStato_Old <> 1) --Lo stato corrente non è attivo 
			AND (@IdStato = 1) --si vuole attivare la sottoscrizione
		BEGIN 
			-- Cancello i dati nella coda referti e documenti onde evitare di mandare in stampa 
			-- vecchi documenti			
			DELETE SS_DC 
			FROM StampeSottoscrizioniDocumentiCoda AS SS_DC INNER JOIN StampeSottoscrizioniCoda AS SS_C ON SS_DC.IdStampeSottoscrizioniCoda = SS_C.Id
			WHERE SS_C.IdStampeSottoscrizioni = @Id
		
			DELETE FROM StampeSottoscrizioniCoda
			WHERE IdStampeSottoscrizioni = @Id
		END 
		
		UPDATE StampeSottoscrizioni
		   SET DataModifica = GETDATE()
			  , DataFine = @DataFine
			  , TipoReferti = @IdTipoReferti
			  , ServerDiStampa = @ServerDiStampa
			  , Stampante = @Stampante
			  , Stato = @IdStato
			  , Nome = @Nome 			  
			  , Descrizione= @Descrizione
			  , StampaConfidenziali = @StampaConfidenziali 
			  , StampaOscurati = @StampaOscurati
			  , NumeroCopie = @NumeroCopie 
		WHERE Id = @Id
			AND Ts = @Ts 

		DECLARE @NumRows AS INTEGER
		SET @NumRows = @@ROWCOUNT 
		IF @NumRows = 0 
		BEGIN
			--DECLARE @ErrorMessage VARCHAR(200)
			--SET @ErrorMessage = 'Il record è stato modificato da un altro utente!'
			--RAISERROR (@ErrorMessage, 16,1)
			IF @@TRANCOUNT > 0
				ROLLBACK
		END
		ELSE
		BEGIN 
			--
			--
			--
			COMMIT
		END 
				
	END TRY
	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
			ROLLBACK
	
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BevsStampeSottoscrizioniAggiorna. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
	
	END CATCH	
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniAggiorna2] TO [ExecuteFrontEnd]
    AS [dbo];

