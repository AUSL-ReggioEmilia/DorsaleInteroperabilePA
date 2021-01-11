



-- =============================================
-- Author:		ETTORE
-- Create date: 2015-05-22
-- Description:	Sostituisce la dbo.FevsCancellazioneRefertoAggiorna
--				Restituisco anche l'Id del referto cosi da creare un TableAdapter Standard e non un QueryTableAdapter
--				Ho aggiunto come paramentro l'account dell'utente per poterlo scrivere nella tabella dbo.Oscuramenti.
--				Le cancellazioni logiche sono state trasformate in oscuramenti, invece di aggiornare la tabella store.RefertiBase
--				inserisco opportuno record in tabella dbo.oscuramenti. 
--				Gestione AnteprimaReferti: in caso di oscuramento di un referto viene impostato il ricalcolo
--				dell'anteprima referti.
--					1) Ricavo l'IdPaziente a cui è associato il referto
--					2) Invoco SP che imposta il ricalcolo dell'anteprima
-- ModifyDate: 2017-12-20: Aggiunto la rinotifica dell'oscuramento verso SOLE
-- ModifyDate: 2018-11-06: Esplicitato i campi ApplicaDWH, ApplicaSole nell'insert dell'oscuramento
-- =============================================
CREATE PROCEDURE [frontend].[CancellazioneRefertoAggiorna]
(
	@Id  uniqueidentifier
	, @Utente VARCHAR(128)
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @IdEsternoReferto VARCHAR(64)
	--
	-- Imposto il tipo di oscuramento da creare
	--
	DECLARE @TipoOscuramento_IdEsternoReferto AS TINYINT
	SET @TipoOscuramento_IdEsternoReferto = 9 --9=Oscuramento per IdEsternoReferto
	--
	-- 
	--
	SELECT 
		@IdPaziente = IdPaziente
		, @IdEsternoReferto = IdEsterno
	FROM store.RefertiBase
	WHERE Id = @Id
	--
	--
	--
	BEGIN TRY
		--
		-- Inizio transazione
		--
		BEGIN TRANSACTION
		--
		-- ETTORE - 2017-12-20: creo l'Id per l'oscuramento da utilizzare dopo per la rinotifica verso SOLE
		--
		DECLARE @IdOscuramento UNIQUEIDENTIFIER = NEWID()
		--
		-- Inerisco nello stato completato (il defaul del campo Stato è 'Completato')
		--
		INSERT INTO dbo.Oscuramenti(Id, TipoOscuramento, IdEsternoReferto, UtenteInserimento, UtenteModifica, ApplicaDWH, ApplicaSole)
		VALUES (@IdOscuramento ,@TipoOscuramento_IdEsternoReferto, @IdEsternoReferto,  @Utente, @Utente, 1, 1) 
		--
		-- ETTORE - 2017-12-20: Inserisco la rinotifica verso SOLE
		--
		EXECUTE [frontend].[CodaRefertiSoleInserisce] @IdOscuramento
		--
		-- Imposto il ricalcolo dell'anteprima referti 
		--
		EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPaziente, 1, 0
		--
		-- Nessun errore: COMMIT 
		--
		COMMIT
		--
		-- Restituisco l'Id del referto cosi da creare un TableAdapter Standard e non un QueryTableAdapter
		--
		SELECT @Id AS IdReferto
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()
		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'CancellazioneRefertoAggiorna. Error: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(10));
		RAISERROR(@report, 16, 1)

	END CATCH
	
END


