


CREATE PROCEDURE [dbo].[PazientiBaseMerge]
(
	  @IdPaziente uniqueidentifier
	, @IdPazienteFuso uniqueidentifier
	, @ProvenienzaFuso varchar(16)
	, @IdProvenienzaFuso varchar(64)
	, @Motivo tinyint
	, @Note text
)
AS
BEGIN

	DECLARE @NewId AS uniqueidentifier
	DECLARE @DataInserimento AS datetime

	SET NOCOUNT ON;
	
	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------
	BEGIN TRAN
	BEGIN TRY
	
		SET @DataInserimento = GetDate()
		SET @NewId = NewId()

		---------------------------------------------------
		-- Inserisce la fusione
		-- ATTENZIONE: il progressivo di funzione non va impostato, si lascia il default a 0
		---------------------------------------------------
		
		-- nuovo merge
		INSERT INTO PazientiFusioni ( 
			  Id
			, IdPaziente
			, IdPazienteFuso
			, DataInserimento
			, Motivo
			, Note
		) VALUES ( 
			  @NewId
			, @IdPaziente
			, @IdPazienteFuso
			, @DataInserimento
			, @Motivo
			, @Note
		)

		-- riassocio le fusioni esistenti 
		INSERT INTO PazientiFusioni ( 
			  Id
			, IdPaziente
			, IdPazienteFuso
			, DataInserimento
			, Motivo
			, Note
		) SELECT NewId(), @IdPaziente, IdPazienteFuso, @DataInserimento, @Motivo, @Note
		  FROM PazientiFusioni
		  WHERE IdPaziente = @IdPazienteFuso 
			AND Abilitato = 1 --(condizione di AND aggiunta il 20/06/2011)

		---------------------------------------------------
		-- Inserisce il sinonimo
		-- ATTENZIONE: il progressivo sinonimo non va impostato, si lascia il default a 0
		---------------------------------------------------

		-- nuovo merge
		INSERT INTO PazientiSinonimi ( 
			  Id
			, IdPaziente
			, Provenienza
			, IdProvenienza
			, DataInserimento
			, Motivo
			, Note
		) VALUES ( 
			  @NewId
			, @IdPaziente
			, @ProvenienzaFuso
			, @IdProvenienzaFuso
			, @DataInserimento
			, @Motivo
			, @Note
		)

		-- riassocio i sinonimi esistenti 
		INSERT INTO PazientiSinonimi ( 
			  Id
			, IdPaziente
			, Provenienza
			, IdProvenienza
			, DataInserimento
			, Motivo
			, Note
		) SELECT NewId(), @IdPaziente, Provenienza, IdProvenienza, @DataInserimento, @Motivo, @Note
		  FROM PazientiSinonimi
		  WHERE IdPaziente = @IdPazienteFuso
			AND Abilitato = 1 --(condizione di AND aggiunta il 20/06/2011)

		-- Disattivo il paziente
		UPDATE Pazienti
		SET   DataModifica = @DataInserimento
			, DataSequenza = @DataInserimento
			, Disattivato = 2
			, DataDisattivazione = @DataInserimento
		WHERE Id = @IdPazienteFuso

		-- Commit
		COMMIT
		
	END TRY	
	BEGIN CATCH
		ROLLBACK
		
		-- Raiserror
		DECLARE @ERROR_MESSAGE nvarchar(2048)
		SET @ERROR_MESSAGE = ERROR_MESSAGE()

		RAISERROR(@ERROR_MESSAGE, 16, 1)
	END CATCH
	
END















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseMerge] TO [DataAccessWs]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseMerge] TO [DataAccessDll]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseMerge] TO [DataAccessUi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseMerge] TO [DataAccessSql]
    AS [dbo];

