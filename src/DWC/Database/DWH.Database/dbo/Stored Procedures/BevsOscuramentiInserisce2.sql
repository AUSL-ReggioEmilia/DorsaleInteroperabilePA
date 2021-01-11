
-- =============================================
-- Author:     SimoneB
-- Create date: 2017-11-07
-- Description: Inserisce una riga di dbo.Oscuramenti (copiata da [dbo].[BevsOscuramentiInserisce])
-- Aggiunti i parametri   @Stato, @IdOscuramentoModificato, @OutputId 
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiInserisce2]
(
 @Titolo varchar(50),
 @Note varchar(1024),
 @AziendaErogante varchar(16),
 @SistemaErogante varchar(16),
 @NumeroNosologico varchar(64),
 @RepartoRichiedenteCodice varchar(16),
 @NumeroPrenotazione varchar(32),
 @NumeroReferto varchar(16),
 @IdOrderEntry varchar(64), 
 @RepartoErogante varchar(64),
 @StrutturaEroganteCodice varchar(64),
 @TipoOscuramento TINYINT,
 @Parola VARCHAR(64) = NULL,
 @IdEsternoReferto VARCHAR(64) = NULL,
 @Utente VARCHAR(128) = NULL,
 @ApplicaDWH BIT = 1,
 @ApplicaSole BIT = 1,
 @Stato VARCHAR(16) = 'Inserito',
 @IdOscuramentoModificato UNIQUEIDENTIFIER = NULL,
 @OutputId UNIQUEIDENTIFIER OUTPUT
)
AS
BEGIN
  SET NOCOUNT OFF

	IF @Utente IS NULL SET @Utente = SUSER_SNAME()
	
	DECLARE @Inseriti TABLE(Id UNIQUEIDENTIFIER)

	IF EXISTS(SELECT * FROM dbo.Oscuramenti WHERE Id = @IdOscuramentoModificato AND IdCorrelazione IS NOT NULL)
		BEGIN
			RAISERROR('L''oscuramento che si vuole modificare è già in corso di modifica da parte di un altro utente.', 16, 1)
			RETURN
		END 
	

	BEGIN TRANSACTION
	 BEGIN TRY
		INSERT INTO dbo.Oscuramenti
		(
			TipoOscuramento,      
			Titolo,    
			AziendaErogante,
			SistemaErogante,
			NumeroNosologico,
			RepartoRichiedenteCodice,
			NumeroPrenotazione,
			NumeroReferto,
			IdOrderEntry,
			Note,
			RepartoErogante,
			StrutturaEroganteCodice,
			Parola,
			IdEsternoReferto,
			UtenteInserimento,
			UtenteModifica,
			ApplicaDWH, 
			ApplicaSole,
			Stato,
			IdCorrelazione
		)
		OUTPUT 
			INSERTED.Id INTO @Inseriti
		VALUES
			(    
			@TipoOscuramento,  
			NULLIF(@Titolo, ''),
			NULLIF(@AziendaErogante, ''),
			NULLIF(@SistemaErogante, ''),
			NULLIF(@NumeroNosologico, ''),
			NULLIF(@RepartoRichiedenteCodice, ''),
			NULLIF(@NumeroPrenotazione, ''),
			NULLIF(@NumeroReferto, ''),
			NULLIF(@IdOrderEntry, ''),
			NULLIF(@Note, ''),
			NULLIF(@RepartoErogante,''),
			NULLIF(@StrutturaEroganteCodice,''),
			NULLIF(@Parola,''),
			NULLIF(@IdEsternoReferto,''),
			@Utente,
			@Utente,
			@ApplicaDWH, 
			@ApplicaSole,
			@Stato,
			@IdOscuramentoModificato
		)
		

		SELECT @OutputId = Id
		FROM @Inseriti

		IF @IdOscuramentoModificato IS NOT NULL
			UPDATE dbo.Oscuramenti 
			SET 
				IdCorrelazione = @OutputId 
			WHERE 
				Id = @IdOscuramentoModificato		

		COMMIT
	END TRY
	BEGIN CATCH
		--
		-- Rollback delle modifiche
		--
		IF @@TRANCOUNT > 0 ROLLBACK
						
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BevsOscuramentiInserisce. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
	
	END CATCH
	
	 

     
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiInserisce2] TO [ExecuteFrontEnd]
    AS [dbo];

