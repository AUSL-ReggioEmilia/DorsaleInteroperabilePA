

/*
	Modifica Ettore 2013-03-05: 
	nuova gestione per importazione storica, se @ImportazioneStorica viene passato dalla data access
	si usa il valore del parametro, altrimenti in caso di cancellazione non fa nulla come faceva prima.

	MODIFICATO SANDRO 2015-11-02: Usa GetPrescrizioniPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]

	MODIFICA ETTORE 2017-11-10: Notifica in tabella CodaRefertiSole
	Modify date: 2019-01-21 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaRefertiAggiungi])
	Modify date: 2020-10-07 - SANDRO - Se cancellazione, rimuove i referti in coda operazione<>2
	Modify date: 2020-10-15   SANDRO: Per notifiche uso nuova SP [CodaRefertiOutputAggiungi]
	Modify date: 2020-12-04   Ettore: Correzione per passare @OperazioneLog al posto di @Operazione
*/
CREATE PROCEDURE [dbo].[ExtRefertiBeforeProcess]
(
	@IdEsterno AS VARCHAR(64), 
	@Operazione AS smallint, --Valori possibili: 0=Inserimento, 1=Modifica, 2=Cancellazione
	@ImportazioneStorica BIT = NULL
)
AS 
BEGIN 
	SET NOCOUNT ON;

	DECLARE @IdReferto UNIQUEIDENTIFIER 
	DECLARE @DataPartizione SMALLDATETIME

	DECLARE @AziendaErogante VARCHAR(16)
	DECLARE @SistemaErogante VARCHAR(16)
	DECLARE @OperazioneLog smallint
	DECLARE @IdCorrelazione VARCHAR(64)
	DECLARE @TimeoutCorrelazione INT
	DECLARE @IdEsternoOrig VARCHAR(64)
	DECLARE @CancellazioneAbilitata INT
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @StatoRichiestaCodice TINYINT
	DECLARE @DataModifica DATETIME
	--
	-- Se @ImportazioneStorica non viene valorizzato dalla data access assumo che non sia una iportazione storica
	-- e quindi eseguo l'inserimento nella CodaRefertiOutput
	--
	SET @ImportazioneStorica = ISNULL(@ImportazioneStorica, 0)
	--
	-- Log delle operazioni di cancellazione referti
	--
	IF @Operazione = 2 
	BEGIN
		--
		-- Modifica Ettore 13/04/2012: questa cerca anche nei riferimenti
		-- 
		-- Legge la PK del referto
		SELECT @IdReferto = ID, @DataPartizione = DataPartizione
			FROM [dbo].[GetRefertiPk](RTRIM(@IdEsterno))
		--
		-- Non segnalo errore se manca il referto in cancellazione: la data access segnalerà un warning
		--			
		IF  NOT (@IdReferto IS NULL)
		BEGIN 
			--
			-- 08/06/2012 Modifica Ettore uso funzione per determinare se referto cancellabile
			--
			SELECT @CancellazioneAbilitata = dbo.GetRefertiCancellabile2(@IdEsterno,  @IdReferto, @DataPartizione)
			IF @CancellazioneAbilitata > 0 
			BEGIN 
				SELECT @IdReferto = Id 
					, @AziendaErogante = AziendaErogante
					, @SistemaErogante = SistemaErogante
					, @IdEsternoOrig = IdEsterno
					, @IdPaziente = IdPaziente
					, @StatoRichiestaCodice = StatoRichiestaCodice 
					, @DataModifica = DataModifica 
				FROM [store].RefertiBase 
				WHERE Id = @IdReferto
					AND DataPartizione = @DataPartizione
				--
				-- Si notifica solo se è avvenuto l'aggancio paziente
				--
				IF @IdPaziente <> '00000000-0000-0000-0000-000000000000' 
				BEGIN 
					IF @ImportazioneStorica = 0 
					BEGIN
						--
						-- Inserimento nella tabella di LOG
						--
						SET @OperazioneLog = 2		--log di cancellazione

						-------------------------------------------------------------------------------------
						-- Eseguo l'inserimento nella tabella di output standard
						-------------------------------------------------------------------------------------

						DECLARE @XmlReferto XML = NULL
						SET @XmlReferto = dbo.GetRefertoXml2(@IdReferto)

						EXEC [dbo].[CodaRefertiOutputAggiungi] @IdReferto, @IdEsternoOrig, @OperazioneLog
													, @AziendaErogante, @SistemaErogante, @XmlReferto

						---------------------------------------------------------------------------------------
						-- Eseguo l'inserimento nella tabella di output SOLE
						---------------------------------------------------------------------------------------

						DECLARE @XmlRefertoSole XML = NULL
						SET @XmlRefertoSole = [sole].[OttieneRefertoXml](@IdReferto)

						EXEC [sole].[CodaRefertiAggiungi] @IdReferto, @OperazioneLog, 'DAE', @AziendaErogante
													, @SistemaErogante, @StatoRichiestaCodice
													, @DataModifica, @XmlRefertoSole
					END
				END
			END
		END 		
	END
	--
	-- Se nessun errore
	--
	SELECT INSERTED_COUNT = 1
	RETURN 0
	
END 






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiBeforeProcess] TO [ExecuteExt]
    AS [dbo];

