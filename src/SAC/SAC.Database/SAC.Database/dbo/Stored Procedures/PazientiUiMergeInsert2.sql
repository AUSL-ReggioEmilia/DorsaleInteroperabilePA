

CREATE PROCEDURE [dbo].[PazientiUiMergeInsert2]
( 
	  @IdPaziente uniqueidentifier
	, @IdPazienteFuso uniqueidentifier
	, @ProvenienzaFuso varchar(16)
	, @IdProvenienzaFuso varchar(64)	
	, @Note text
	, @Utente varchar(64)
)
AS
BEGIN

DECLARE @Motivo tinyint

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------
	BEGIN TRAN
	BEGIN TRY
	
		SET @Motivo = 3

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
		
		-- Notifica
		-- Modifica Ettore 2013-03-01: notifico operazione merge da UI Tipo=5
		--
		exec PazientiNotificheAdd @IdPazienteFuso, 5, @Utente
			
		-- Completato
		COMMIT
		RETURN 0
		
	END TRY
	BEGIN CATCH
		ROLLBACK
		RETURN 1
	END CATCH	
	
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiMergeInsert2] TO [DataAccessUi]
    AS [dbo];

