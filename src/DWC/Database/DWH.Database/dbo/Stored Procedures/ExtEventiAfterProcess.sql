


-- =============================================
-- Author:		
-- Create date: 
-- Description:	Completa l'operazione di inserimento di un evento scrivendo nelle tabelle di notifica
-- Modify date: 2017-11-10 ETTORE: aggiundo la notifica nella tabella di coda SOLE
-- Modify date: 2017-12-18 ETTORE: Gestito il NULL del campo @TipoRicoveroCodice
-- Modify date: 2017-12-29 ETTORE: Si inviano a SOLE solo alcuni tipi di eventi ADT di ricovero (non si inviano gli eventi delle liste di prenotazione)
--									Per inserire nella coda SOLE devono essere verificate le seguenti condizioni: 
--									@RicoveroStatoCodice <> 255 AND @TipoEventoCodice IN ('A','D','R','X','E') AND @TipoRicoveroCodice IN ('O','D','A')
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2019-01-15 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaEventiAggiungi])
-- Modify date: 2019-02-25 - SANDRO - Aggiunto @StatoCodice a EXEC [sole].[CodaEventiAggiungi]
-- Modify date: 2020-02-27 - ETTORE - Aggiornamento tabella "ultimi arrivi" [ASMN 7707]
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore "Evento non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiAfterProcess]
(
	@IdEsterno AS VARCHAR(64), 
	@Operazione AS smallint --Aggiornamento=0, Rimozione=1
)
AS 
BEGIN 

	SET NOCOUNT ON;
	----------------------------------------------------------
	-- Log eventi in caso di aggiornamento
	----------------------------------------------------------
	DECLARE @IdEvento AS UNIQUEIDENTIFIER 
	DECLARE @DataInserimento AS DATETIME 
	DECLARE @DataModifica AS DATETIME 
	DECLARE @AziendaErogante AS VARCHAR(16)
	DECLARE @SistemaErogante AS VARCHAR(16)
	DECLARE @NumeroNosologico AS VARCHAR(64)
	DECLARE @OperazioneLog AS smallint
	DECLARE @IdCorrelazione AS VARCHAR(64)
	DECLARE @TimeoutCorrelazione INT
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @TipoEventoCodice VARCHAR(16)
	DECLARE @StatoCodice TINYINT
	
	IF @Operazione = 0	--se è un aggiornamento
	BEGIN
		SELECT @IdEvento = Id 
			, @DataInserimento = DataInserimento
			, @DataModifica = DataModifica 
			, @AziendaErogante = AziendaErogante
			, @SistemaErogante = SistemaErogante 
			, @NumeroNosologico = NumeroNosologico 
			, @IdPaziente = IdPaziente
			, @TipoEventoCodice = TipoEventoCodice
			, @StatoCodice = StatoCodice
		FROM [store].[EventiBase]
		WHERE IdEsterno = @IdEsterno
			
		IF @IdEvento IS NULL
		BEGIN 
			--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
			RAISERROR('Errore evento non trovato!', 16, 1)
			RETURN 1002	--Errore "Evento non trovato"
		END 
		--
		-- Si notifica solo se è avvenuto l'aggancio paziente
		--
		IF @IdPaziente <> '00000000-0000-0000-0000-000000000000' 
		BEGIN 
			--
			-- Inserimento nella tabella di LOG
			--
			SET @OperazioneLog = 1		--log di modifica
			IF @DataInserimento = @DataModifica
				SET @OperazioneLog = 0	--log di inserimento
			--
			-- Valorizzo l'Id di correlazione
			--
			SELECT @IdCorrelazione =  [dbo].[GetCodaEventiOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante,  @NumeroNosologico)
			--
			-- Valorizzo il timeout di correlazione
			--
			SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput',	'TimeoutCorrelazione'), 1)

			---------------------------------------------------------------------------
			-- Eseguo l'inserimento nella tabella di out standard
			---------------------------------------------------------------------------				
			INSERT INTO CodaEventiOutput (IdEvento, Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
			VALUES(@IdEvento, @OperazioneLog , @IdCorrelazione, @TimeoutCorrelazione, 0, dbo.GetEventoXml2(@IdEvento))
			
			-----------------------------------------------------------------------------
			-- Eseguo l'inserimento nella tabella di coda SOLE
			--	 --2019-01-16
			-----------------------------------------------------------------------------

			-- 2019-01-16 Precarico messaggio solo in cancellazione

			EXEC [sole].[CodaEventiAggiungi] @IdEvento, @OperazioneLog, 'DAE', @AziendaErogante, @SistemaErogante, @StatoCodice
											, @TipoEventoCodice, @DataModifica, @NumeroNosologico, NULL 
		END
		--
		-- Modify date: 2020-02-27 - ETTORE - Aggiunto aggiornamento per "ultimi arrivi" [ASMN 7707]
		--
		EXECUTE [sinottico].[UltimiArriviEventiAggiorna] @AziendaErogante, @SistemaErogante

	END
	--
	-- Se nessun errore
	--
	SELECT INSERTED_COUNT = 1
	RETURN 0
END 




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiAfterProcess] TO [ExecuteExt]
    AS [dbo];

