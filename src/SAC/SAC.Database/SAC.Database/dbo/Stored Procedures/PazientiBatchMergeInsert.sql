
CREATE PROCEDURE [dbo].[PazientiBatchMergeInsert]
	( @IdPaziente uniqueidentifier
	, @IdPazienteFuso uniqueidentifier
	, @Provenienza varchar(16)
	, @IdProvenienza varchar(64)
	)
AS
BEGIN

DECLARE @DataInserimento AS datetime
DECLARE @Id AS uniqueidentifier

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	BEGIN TRY

		SET @DataInserimento = GetDate()
		SET @Id = NewId()
		
		--
		-- Modifica Ettore: 2012-12-03: controllo che l'id del paziente da fondere non sia già fuso
		--
		DECLARE @Disattivato TINYINT
		SELECT @Disattivato = Disattivato FROM Pazienti WHERE Id = @IdPazienteFuso
		IF @Disattivato = 2 
		BEGIN 
			DECLARE @ErroMsg VARCHAR(200)
			SET @ErroMsg = 'Impossibile eseguire la fusione: il paziente con Id=' + CAST(@IdPazienteFuso AS VARCHAR(40)) + ' è già fuso!'
			RAISERROR(@ErroMsg, 16, 1)
		END

		---------------------------------------------------
		-- Inserisce la fusione
		-- ATTENZIONE: il progressivo di funzione non va impostato nella insert, si lascia il default a 0
		---------------------------------------------------
		
		-- nuovo merge
		INSERT INTO PazientiFusioni
			( Id
			, IdPaziente
			, IdPazienteFuso
			, DataInserimento
			, Motivo
			, Note
			)
		VALUES
			( @Id
			, @IdPaziente
			, @IdPazienteFuso
			, @DataInserimento
			, 2
			, 'BatchMerge'
			)

		--IF @@ERROR <> 0 GOTO ERROR_EXIT

		-- riassocio quelli già esistenti 
		INSERT INTO PazientiFusioni
			( Id
			, IdPaziente
			, IdPazienteFuso
			, DataInserimento
			, Motivo
			, Note
			)
			SELECT NewId()
				, @IdPaziente
				, IdPazienteFuso
				, GetDate()
				, 2
				, 'BatchMerge'
			FROM PazientiFusioni
			WHERE IdPaziente = @IdPazienteFuso
				AND Abilitato = 1 --(condizione di AND aggiunta il 20/06/2011)

		---------------------------------------------------
		-- Inserisce il sinonimo
		-- ATTENZIONE: il progressivo sinonimo non va impostato nella insert, si lascia il default a 0
		---------------------------------------------------

		-- nuovo merge
		INSERT INTO PazientiSinonimi
			( Id
			, IdPaziente
			, Provenienza
			, IdProvenienza
			, DataInserimento
			, Motivo
			, Note
			)
		VALUES
			( @Id
			, @IdPaziente
			, @Provenienza
			, @IdProvenienza
			, @DataInserimento
			, 2
			, 'BatchMerge'
			)

		-- riassocio quelli già esistenti 
		INSERT INTO PazientiSinonimi
			( Id
			, IdPaziente
			, Provenienza
			, IdProvenienza
			, DataInserimento
			, Motivo
			, Note
			)
			SELECT NewId()
				, @IdPaziente
				, Provenienza
				, IdProvenienza
				, GetDate()
				, 2
				, 'BatchMerge'
			FROM PazientiSinonimi
			WHERE IdPaziente = @IdPazienteFuso
				AND Abilitato = 1 --(condizione di AND aggiunta il 20/06/2011)

		---------------------------------------------------
		-- Aggiorno il campo Disattivato della tab. Pazienti
		---------------------------------------------------
		UPDATE Pazienti
		SET   DataModifica = GetDate()
			--, DataSequenza = GetDate()
			, Disattivato = 2
			, DataDisattivazione = GetDate()
			
		WHERE Id = @IdPazienteFuso

		-- COMMIT
		COMMIT TRAN

	END TRY
	BEGIN CATCH
		-- ROLLBACK
		ROLLBACK TRAN

		DECLARE @ErrorMessage varchar(4000)
		SELECT @ErrorMessage =
			'ErrorNumber: ' + CONVERT(varchar(8), ERROR_NUMBER()) +
			', Severity: ' + CONVERT(varchar(8), ERROR_SEVERITY()) +
			', State: ' + CONVERT(varchar(8), ERROR_STATE()) + 
			', Procedure: ' + ISNULL(ERROR_PROCEDURE(), '-') + 
			', Line: ' + CONVERT(varchar(8), ERROR_LINE()) +
			', Message: ' + ISNULL(ERROR_MESSAGE(), '-')
		RAISERROR(@ErrorMessage, 16, 1)
		
	END CATCH


END

