


/*
	Modifica Ettore 2013-03-05: 
	nuova gestione per importazione storica, se @ImportazioneStorica viene passato dalla data access
	si usa il valore del parametro, altrimenti si ricava se l'importazione è storica dall'attributo
	come si faceva prima.
	
	MODIFICATO SANDRO 2015-11-02: Usa GetRefertiPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]

	MODIFICA ETTORE 2017-11-10: Notifica in tabella CodaRefertiSole
	Modify date: 2019-01-21 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaRefertiAggiungi])
	Modify date: 2020-02-27 - ETTORE - Aggiornamento tabella "ultimi arrivi" [ASMN 7707]
	Modify date: 2020-06-24 - ETTORE - Inserimento referto nella coda per il calcolo delle "avvertenze" [ASMN 5754]
	Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore "Evento non trovato"
	Modify date: 2020-10-02   Sandro: Per velocizzare le operazioni, il campo Messaggio contente XMl del referto sara lasciato NULL
								         La SP [dbo].[BtCodaRefertiOutputOttieni] lo calcolerà con [dbo].[GetRefertoXml2](@IdReferto)
										 al momento della notifica.
	Modify date: 2020-10-15   Sandro: Per notifiche uso nuova SP [CodaRefertiOutputAggiungi]
	Modify date: 2020-12-04   Ettore: Correzione per passare @OperazioneLog al posto di @Operazione

*/
CREATE PROCEDURE [dbo].[ExtRefertiAfterProcess]
(
	@IdEsterno AS VARCHAR(64), 
	@Operazione AS smallint, --Valori possibili: 0=Inserimento, 1=Modifica, 2=Cancellazione
	@ImportazioneStorica BIT = NULL
)
AS 
BEGIN 
	SET NOCOUNT ON;
	DECLARE @IdReferto AS UNIQUEIDENTIFIER 
	DECLARE @DataInserimento AS DATETIME 
	DECLARE @DataModifica AS DATETIME 
	DECLARE @AziendaErogante AS VARCHAR(16)
	DECLARE @SistemaErogante AS VARCHAR(16)
	DECLARE @OperazioneLog AS smallint
	DECLARE @IdEsternoOrig VARCHAR(64)
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @StatoRichiestaCodice TINYINT

	----------------------------------------------------------
	-- Log inserimento/modifica dei Referti
	----------------------------------------------------------
	IF @Operazione <> 2 
	BEGIN
		--
		-- Cerco i dati del referto
		--
		SELECT 
			@IdReferto = RefertiBase.Id 
			, @DataInserimento = DataInserimento
			, @DataModifica = DataModifica 
			, @AziendaErogante = AziendaErogante
			, @SistemaErogante = SistemaErogante
			, @IdEsternoOrig = IdEsterno
			, @IdPaziente = IdPaziente
			, @StatoRichiestaCodice = StatoRichiestaCodice 
		FROM [store].RefertiBase 
			INNER JOIN [dbo].[GetRefertiPk](RTRIM(@IdEsterno)) PK
				ON RefertiBase.Id = PK.ID
				AND RefertiBase.DataPartizione = PK.DataPartizione

		IF @IdReferto IS NULL
		BEGIN 
			--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
			RAISERROR('Errore referto non trovato!', 16, 1)
			RETURN 1002	--Errore "Referto non trovato"
		END 
		--
		-- Si notifica solo se è avvenuto l'aggancio paziente
		--
		IF @IdPaziente <> '00000000-0000-0000-0000-000000000000' 			
		BEGIN
			IF @ImportazioneStorica IS NULL
			BEGIN 
				--
				-- Verifico se è una importazione storica leggendo dagli attributi (per compatibilità)
				--	
				DECLARE @ImpStorica varchar(1) --valori: 0,1
				SELECT @ImpStorica = CAST(Valore AS VARCHAR(1))
					FROM [store].RefertiAttributi 
					WHERE IdRefertiBase = @IdReferto AND Nome = 'ImportazioneStorica'

				SET @ImpStorica = ISNULL(@ImpStorica,'0')
				SET @ImportazioneStorica = 0
				IF @ImpStorica = '1'
					SET @ImportazioneStorica = 1
			END
			--
			-- Verifico se è una importazione storica
			--	
			IF @ImportazioneStorica = 0 
			BEGIN
				--
				-- Determino se inserimento/aggiornamento
				--
				SET @OperazioneLog = 1		--log di modifica
				IF @DataInserimento = @DataModifica
					SET @OperazioneLog = 0	--log di inserimento
					
				-------------------------------------------------------------------
				-- Eseguo l'inserimento nella tabella di output standard
				-- dal 2020-10-02 Messaggio = NULL non più dbo.GetRefertoXml2(@IdReferto)
				--
				-------------------------------------------------------------------

				EXEC [dbo].[CodaRefertiOutputAggiungi] @IdReferto, @IdEsternoOrig, @OperazioneLog
											, @AziendaErogante, @SistemaErogante, NULL

				---------------------------------------------------------------------------
				-- Eseguo l'inserimento nella tabella di output SOLE
				----------------------------------------------------------------------------

				EXEC [sole].[CodaRefertiAggiungi] @IdReferto, @OperazioneLog, 'DAE', @AziendaErogante
											, @SistemaErogante, @StatoRichiestaCodice
											, @DataModifica, NULL
			END 
		END

		-- Modify date: 2020-02-27 - ETTORE - Aggiornamento tabella "ultimi arrivi" [ASMN 7707]
		EXECUTE [sinottico].[UltimiArriviRefertiAggiorna] @AziendaErogante, @SistemaErogante

		--Modify date: 2020-06-24 - ETTORE - Inserimento referto nella coda per il calcolo delle "avvertenze" [ASMN 5754]
		EXEC [dbo].[ExtRefertiAvvertenzeCodaAggiungi] @IdReferto ,@AziendaErogante ,@SistemaErogante 

	END
	--
	-- Se nessun errore
	--
	SELECT INSERTED_COUNT = 1
	RETURN 0
END 






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiAfterProcess] TO [ExecuteExt]
    AS [dbo];

