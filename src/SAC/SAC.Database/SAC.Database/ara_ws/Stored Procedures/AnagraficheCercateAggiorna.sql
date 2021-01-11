
-- =============================================
-- Author:		Ettore
-- Create date: 2020-10-20
-- Description:	Dopo la ricerca fatta da PazientiCercaExt() salva le anagrafiche ARA assegnandogli un IdSac (compresa la risposta di ARA)
--				(insert into se non esiste per IdProvenienza altrimenti aggiorna i campi Risposta e DataRisposta) 
--				e restituisce i record con IdSAC valorizzato al chiamante che li userà per restituire il dataset
--				Restituzione dei dati fuori dalla transazione
-- =============================================
CREATE PROCEDURE [ara_ws].[AnagraficheCercateAggiorna]
(
	@Identity VARCHAR(64)
	,@AnagraficheCercate AS ara.AnagraficheCercate READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	BEGIN TRANSACTION
	BEGIN TRY
		--
		-- Inserisco gli idprovenienza ARA nella tabella cosi si valorizza IdSac
		--
		INSERT INTO ara.AnagraficheCercate(IdProvenienza, Risposta)
		SELECT 
			IdProvenienza 
			, Risposta 
		FROM 
			@AnagraficheCercate AS TAB
		WHERE 
			NOT EXISTS (SELECT * FROM ara.AnagraficheCercate AS AC 
						WHERE AC.IdProvenienza = TAB.IdProvenienza
						)
		--
		-- Aggiornamento delle AnagraficheCercate esistenti
		--
		UPDATE AC
			SET AC.Risposta = TAB.Risposta
				, AC.DataRisposta = GETUTCDATE()
		FROM ara.AnagraficheCercate AS AC
			INNER JOIN @AnagraficheCercate AS TAB
				ON AC.IdProvenienza = TAB.IdProvenienza
		--
		-- COMMIT
		--
		COMMIT

		--
		-- Restituisco i dati con IdSac valorizzato
		-- Il campo "Risposta" a questo punto non serve, sarà usato nel metodo di dettaglio
		--
		SELECT 
			AC.IdSac
			, AC.IdProvenienza
		FROM 
			ara.AnagraficheCercate AS AC
			INNER JOIN @AnagraficheCercate AS TAB
				ON AC.IdProvenienza = TAB.IdProvenienza

	END TRY
	BEGIN CATCH
		---------------------------------------------------
		--     ROLLBACK TRANSAZIONE
		---------------------------------------------------
		IF @@TRANCOUNT > 0 ROLLBACK

		---------------------------------------------------
		--     GESTIONE ERRORI (LOG E PASSO FUORI)
		---------------------------------------------------
		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE()    
		EXEC dbo.PazientiEventiAvvertimento @Identity, 0, @ProcName, @ErrMsg
		-- PASSO FUORI L'ECCEZIONE
		; THROW

	END CATCH
END