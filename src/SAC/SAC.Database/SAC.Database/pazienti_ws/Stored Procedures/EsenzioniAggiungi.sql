

-- =============================================
-- Author:		SimoneB
-- Create date: 2018-03-26
-- Description:	Aggiunta di una Esenzione
-- =============================================
CREATE PROCEDURE [pazienti_ws].[EsenzioniAggiungi]
(
	@Identity varchar(64)
	,@IdPaziente uniqueidentifier
	,@CodiceEsenzione varchar(32)
    ,@CodiceDiagnosi varchar(32)
    ,@Patologica bit
    ,@DataInizioValidita datetime
    ,@DataFineValidita datetime
    ,@NumeroAutorizzazioneEsenzione varchar(64)
    ,@NoteAggiuntive varchar(2048)
    ,@CodiceTestoEsenzione varchar(64)
    ,@TestoEsenzione varchar(2048)
    ,@DecodificaEsenzioneDiagnosi varchar(1024)
    ,@AttributoEsenzioneDiagnosi varchar(1024)
    ,@OperatoreId VARCHAR(64)
	,@OperatoreCognome VARCHAR(64)
	,@OperatoreNome VARCHAR(64)
	,@OperatoreComputer VARCHAR(64)
)
AS
BEGIN

	DECLARE @Id uniqueidentifier = NewId()
	DECLARE @DataInserimento AS datetime = GetDate()
	DECLARE @Provenienza varchar(16)
	DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

	BEGIN TRY

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	IF [dbo].[LeggeEsenzioniPermessiScrittura](@Identity) = 0
	BEGIN
		EXEC [dbo].[EsenzioniEventiInserisce] @Identity, 0,'ACCESSO NEGATO',@ProcName, 'Utente non ha i permessi di scrittura sulle esenzioni!'
		RAISERROR('Errore di controllo accessi!', 16, 1)
		RETURN
	END
		
	---------------------------------------------------
	-- Calcolo provenienza da Identity
	-----------------------------------------------------
	SET @Provenienza = [dbo].[LeggeEsenzioniProvenienza](@Identity)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore Provenienza non trovata!', 16, 1)
		RETURN
	END


	---------------------------------------------------
	--  Verifico se il paziente esiste
	---------------------------------------------------
	IF NOT EXISTS (SELECT *
				FROM dbo.Pazienti
				WHERE id = @IdPaziente)
	BEGIN
 	 	DECLARE @msgPazienteMancante VARCHAR(256)= 'Il paziente con id ' + CAST(@IdPaziente AS VARCHAR(40)) + ' non esiste.'
	 	RAISERROR(@msgPazienteMancante, 16, 1)
		RETURN
	END 

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------
	BEGIN TRAN

		INSERT INTO [dbo].[PazientiEsenzioni]
           ([Id]
           ,[IdPaziente]
		   ,[DataInserimento]
		   ,[DataModifica]
           ,[CodiceEsenzione]
           ,[CodiceDiagnosi]
           ,[Patologica]
           ,[DataInizioValidita]
           ,[DataFineValidita]
           ,[NumeroAutorizzazioneEsenzione]
           ,[NoteAggiuntive]
           ,[CodiceTestoEsenzione]
           ,[TestoEsenzione]
           ,[DecodificaEsenzioneDiagnosi]
           ,[AttributoEsenzioneDiagnosi]
		   ,[OperatoreId]
		   ,[OperatoreCognome]
		   ,[OperatoreNome]
		   ,[OperatoreComputer]
           ,[Provenienza])
	OUTPUT
		INSERTED.Id
		, INSERTED.IdPaziente
		, INSERTED.CodiceEsenzione
		, INSERTED.CodiceDiagnosi
		, INSERTED.Patologica
		, INSERTED.DataInizioValidita
		, INSERTED.DataFineValidita
		, INSERTED.NumeroAutorizzazioneEsenzione
		, INSERTED.NoteAggiuntive
		, INSERTED.CodiceTestoEsenzione
		, INSERTED.TestoEsenzione
		, INSERTED.DecodificaEsenzioneDiagnosi
		, INSERTED.AttributoEsenzioneDiagnosi
		, INSERTED.Provenienza
		, INSERTED.OperatoreId
		, INSERTED.OperatoreCognome
		, INSERTED.OperatoreNome
		, INSERTED.OperatoreComputer
		, INSERTED.Provenienza
     VALUES
           (@Id
           ,@IdPaziente
		   ,@DataInserimento
		   ,@DataInserimento
           ,@CodiceEsenzione
           ,@CodiceDiagnosi
           ,@Patologica
           ,@DataInizioValidita
           ,@DataFineValidita
           ,@NumeroAutorizzazioneEsenzione
           ,@NoteAggiuntive
           ,@CodiceTestoEsenzione
           ,@TestoEsenzione
           ,@DecodificaEsenzioneDiagnosi
           ,@AttributoEsenzioneDiagnosi
		   ,@OperatoreId
		   ,@OperatoreCognome
		   ,@OperatoreNome
		   ,@OperatoreComputer
           ,@Provenienza)

		---------------------------------------------------
		-- Inserisce record di notifica
		---------------------------------------------------
		--Mi assicuro che sia il paziente attivo
		SELECT @IdPaziente = [dbo].[GetPazienteRootByPazienteId] (@IdPaziente)
		EXEC dbo.PazientiNotificheAdd @IdPaziente, 9, @Identity
	
		COMMIT	
		
	END TRY
		BEGIN CATCH

		---------------------------------------------------
		--     ROLLBACK TRANSAZIONE
		---------------------------------------------------
		IF @@TRANCOUNT > 0 ROLLBACK

		---------------------------------------------------
		--     GESTIONE ERRORI (LOG E PASSO FUORI)
		---------------------------------------------------
	    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE()    
		
		EXEC [dbo].[EsenzioniEventiInserisce] @Identity, 0,'AVVERTIMENTO',@ProcName,@msg
		
		-- PASSO FUORI L'ECCEZIONE
		;THROW;

	END CATCH

	
END