

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-01-15
-- Modify date: 2019-02-25 Aggiunto paramentro @StatoCodice
--							Se @@StatoRichiestaCodice = Cancellazione non invio il precedenti
-- Modify date: 2019-04-03 Aggiunto motivo
-- Modify date: 2019-04-11 Aggiunti nuovo campi a rimossi
--							Rimuovo anche referti se aggiornamento
-- Modify date: 2019-05-10 Aggiunto camopo NumeroNosologico alle code
--							Usa nuova SP [sole].[RefertiRimuovoAncoraDaInviare]
-- Modify date: 2020-03-31 Controllo prestazioni, introdotto per CoronaVirus
-- Modify date: 2020-06-04 Rimossa coda doppia temporanea
-- Modify date: 2020-11-17 Aggiunto controllo Firmato
-- Modify date: 2020-11-27 Aggiunto Flag di invio NonFirmati
--
-- Description:	Aggiunge alla cosa SOLE un referto
-- =============================================
CREATE PROCEDURE [sole].[CodaRefertiAggiungi]
(
 @IdReferto AS UNIQUEIDENTIFIER
,@Operazione SMALLINT
,@Sorgente VARCHAR(64) --valori possibili: 'DAE', 'Oscuramenti', 'Admin', 'Mnt'
,@AziendaErogante VARCHAR(16)
,@SistemaErogante AS VARCHAR(16)
,@StatoRichiestaCodice TINYINT
,@DataModificaReferto DATETIME
,@XmlRefertoErase XML
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- Flag di prodedura
	--
	DECLARE @FlagInviaNonFirmato BIT = 1
	--
	-- Variabili
	--
	DECLARE @Abilitato BIT = 0
	DECLARE @Priorita INT = 6
	DECLARE @OreRitardoInvio INT = 24
	DECLARE @TipologiaSole VARCHAR(16)
	--
	-- Abilitazioni
	--
	SELECT @Abilitato = Abilitato
		,@Priorita = Priorita
		,@OreRitardoInvio = OreRitardoInvio
		,@TipologiaSole = TipologiaSole

	FROM [sole].[AbilitazioniSistemi] a
	WHERE a.AziendaErogante = @AziendaErogante
		AND a.SistemaErogante = @SistemaErogante
		AND a.TipoErogante = 'Referto'

	IF ISNULL(@Abilitato, 0) = 1
	BEGIN
		--
		-- Ottengo e comprimo i messaggio (solo se cancellazione)
		--
		DECLARE @XmlRefertoCompress VARBINARY(MAX) = NULL

		IF @Operazione = 2 AND NOT @XmlRefertoErase IS NULL
		BEGIN
			SET @XmlRefertoCompress = dbo.compress(CONVERT(VARBINARY(MAX), @XmlRefertoErase))
		END

		--Paziente di prova dare precedenza e Nosologico
		-- Limito ricerca negli ultimi store
		--
		DECLARE @PazienteCodiceFiscale VARCHAR(16) = NULL
		DECLARE @NumeroNosologico VARCHAR(64) = NULL
		DECLARE @Firmato BIT = NULL

		SELECT @PazienteCodiceFiscale = NULLIF(RTRIM([CodiceFiscale]), '')
			,@NumeroNosologico = NULLIF(RTRIM([NumeroNosologico]), '')
			,@Firmato = Firmato
		FROM [store].[Referti] WHERE [Id] = @IdReferto
			AND [DataPartizione] > DATEADD(YEAR, -3, @DataModificaReferto)
		OPTION (RECOMPILE)

		IF @PazienteCodiceFiscale = 'SSSRGN75B01H223A'
		BEGIN
			SET @Priorita = 0
			SET @OreRitardoInvio = 0
		END

		IF @Sorgente = 'Oscuramenti'
		BEGIN
			SET @Priorita = 8	--Di notte
			SET @OreRitardoInvio = 0
		END
		--
		-- Eseguo l'inserimento nella tabella di coda SOLE: l'inserimento nella coda SOLE deve essere fatto solo 
		--
		-- Escludo referti in bozza @RicoveroStatoCodice deve essere diverso da 0 e non firmati
		-- oppure è una cancellazione

		IF (ISNULL(@StatoRichiestaCodice, 0) <> 0 AND (@Firmato = 1 OR @FlagInviaNonFirmato = 1))
			OR @Operazione = 2
		BEGIN
			--
			-- Controllo prestazioni per Urgenza invio e ByPass blocchi
			--
			DECLARE	@trovati INT = 0
			DECLARE @PrestazioneCodici VARCHAR(MAX) = NULL
			DECLARE @DisabilitaControlliBloccoInvio BIT = NULL
			DECLARE @PrestazioneOreRitardoInvio INT = NULL

			IF @Operazione <> 2
			BEGIN
				--
				-- Se non è una cancellazione controlla PRESTAZIONI
				--
				EXEC @trovati = [sole].[CodaRefertiControlloPrestazioni] @IdReferto, @AziendaErogante, @SistemaErogante,
															@PrestazioneCodici OUTPUT, @DisabilitaControlliBloccoInvio OUTPUT,
															@PrestazioneOreRitardoInvio OUTPUT
				IF @trovati > 0
				BEGIN
					-- Trovata una prestazione
					-- Sovrascrive il ritardo di invio, se NULL non modifico
					--
					SET @OreRitardoInvio = ISNULL(@PrestazioneOreRitardoInvio, @OreRitardoInvio)
					--
					-- Uso il campo messaggio, usato solo per le cancellazioni
					-- Salvo info ri ritorno dal processo di controllo prestazioni
					--
					DECLARE @XmlControlloPrestazioni XML = CONVERT(XML, (
								SELECT	@trovati as  N'Trovati',
										@PrestazioneCodici as N'PrestazioneCodici',
										@DisabilitaControlliBloccoInvio as N'DisabilitaControlliBloccoInvio',
										@PrestazioneOreRitardoInvio as N'OreRitardoInvio'
								FOR XML RAW ('ControlloPrestazioni')
								)
							)
					SET @XmlRefertoCompress = dbo.compress(CONVERT(VARBINARY(MAX), @XmlControlloPrestazioni))

				END  -- trovati > 0
			END -- Operazione <> 2
			--
			-- Rimuovo dalla coda degli eventi simili al corrente perche' poi sarebbero inviati più volta
			-- a seguiti di cancellazioni e aggiornamenti
			--
			EXEC [sole].[CodaRefertiRimuoveDaInviare] @IdReferto, @Operazione, @StatoRichiestaCodice
															 ,@AziendaErogante, @SistemaErogante, @NumeroNosologico
															, @TipologiaSole
			--
			-- Aggiungo alla coda per SOLE
			--
			INSERT INTO [sole].[CodaReferti]
				([IdReferto], [Operazione], [Sorgente], [AziendaErogante], [SistemaErogante]
				, [StatoRichiestaCodice], [DataModificaReferto]
				, [Priorita], [OreRitardoInvio], [Messaggio], [NumeroNosologico])
			VALUES
				(@IdReferto, @Operazione, @Sorgente, @AziendaErogante, @SistemaErogante
				,@StatoRichiestaCodice, @DataModificaReferto
				,@Priorita, @OreRitardoInvio, @XmlRefertoCompress, @NumeroNosologico)

		END
	END
END