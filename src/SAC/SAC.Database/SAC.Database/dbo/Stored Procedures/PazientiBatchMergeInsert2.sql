

CREATE PROCEDURE [dbo].[PazientiBatchMergeInsert2]
( 
	  @IdPaziente uniqueidentifier
	, @IdPazienteFuso uniqueidentifier
	, @ProvenienzaFuso varchar(16)
	, @IdProvenienzaFuso varchar(64)
)
AS
BEGIN

DECLARE @Motivo tinyint
DECLARE @Note varchar(32)
	
	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------
	BEGIN TRAN
	BEGIN TRY
	
		SET @Motivo = 2
		SET @Note = 'BatchMerge'

		-- Demerge della vittima PER SICUREZZA
		EXEC PazientiBaseDeMerge @IdPazienteFuso	
		
		-- Demerge del vincente
		EXEC PazientiBaseDeMerge @IdPaziente	
		
		-- Fusione richiesta
		EXEC PazientiBaseMerge @IdPaziente = @IdPaziente
							 , @IdPazienteFuso = @IdPazienteFuso
							 , @ProvenienzaFuso = @ProvenienzaFuso
							 , @IdProvenienzaFuso = @IdProvenienzaFuso
							 , @Motivo = @Motivo
							 , @Note = @Note 
		
		-- Completato
		COMMIT
		
	END TRY
	BEGIN CATCH
		ROLLBACK
	END CATCH	

END















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBatchMergeInsert2] TO [DataAccessDll]
    AS [dbo];

