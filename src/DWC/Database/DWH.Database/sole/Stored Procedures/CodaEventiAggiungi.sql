


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-01-15
-- Modify date: 2019-02-25 Aggiunto paramentro @StatoCodice
--							Se @StatoCodice = Cancellazione non invio il precedenti
--							Se @TipoEventoCodice = Erase non invio tutti i precedenti
-- Modify date: 2019-04-03 Aggiunto motivo
--							Se @TipoRicoveroCodice vuoto leggo da evento
-- Modify date: 2019-04-11 Aggiunti nuovo campi a rimossi
--							Rimuovo anche referti se aggiornamento
-- Modify date: 2019-05-10 Aggiunto camopo NumeroNosologico alle code
--							Usa nuova SP [sole].[EventiRimuovoAncoraDaInviare]
-- Modify date: 2020-06-04 Rimossa coda doppia temporanea
--
-- Description:	Aggiunge alla cosa SOLE un evento
-- =============================================
CREATE PROCEDURE [sole].[CodaEventiAggiungi]
(
 @IdEvento AS UNIQUEIDENTIFIER
,@Operazione SMALLINT
,@Sorgente VARCHAR(64) --valori possibili: 'DAE', 'Oscuramenti', 'Admin', 'Mnt'
,@AziendaErogante VARCHAR(16)
,@SistemaErogante AS VARCHAR(16)
,@StatoCodice TINYINT
,@TipoEventoCodice VARCHAR(16)
,@DataModificaEvento DATETIME
,@NumeroNosologico VARCHAR(64)
,@XmlEventoErase XML
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Abilitato BIT = 0
	DECLARE @Priorita INT = 6
	DECLARE @OreRitardoInvio INT = 24
	--
	-- Abilitazioni
	--
	SELECT @Abilitato = Abilitato
		,@Priorita = Priorita
		,@OreRitardoInvio = OreRitardoInvio
	FROM [sole].[AbilitazioniSistemi] a
	WHERE a.AziendaErogante = @AziendaErogante
		AND a.SistemaErogante = @SistemaErogante
		AND a.TipoErogante = 'Evento'

	IF ISNULL(@Abilitato, 0) = 1
	BEGIN
		--
		-- Dati del ricovero da verificare
		-- Limito ricerca negli ultimi store
		--
		DECLARE @RicoveroStatoCodice TINYINT
		DECLARE @TipoRicoveroCodice VARCHAR(16)
		DECLARE @PazienteCodiceFiscale VARCHAR(16)
			
		SELECT @RicoveroStatoCodice = StatoCodice
			, @TipoRicoveroCodice = TipoRicoveroCodice
			, @PazienteCodiceFiscale = CodiceFiscale
		FROM [store].[Ricoveri] 
		WHERE [AziendaErogante] = @AziendaErogante
			AND [NumeroNosologico] = @NumeroNosologico
			AND [DataPartizione] > DATEADD(YEAR, -3, @DataModificaEvento)
		--
		-- 2019-04-03
		--
		IF NULLIF(@TipoRicoveroCodice, '') IS NULL
		BEGIN
			SELECT @TipoRicoveroCodice = TipoEpisodio
			FROM [store].[Eventi]
			WHERE [Id] = @IdEvento
		END
		--
		-- Ottengo e comprimo i messaggio (solo se cancellazione)
		--
		DECLARE @XmlEventoCompress VARBINARY(MAX) = NULL

		IF @Operazione = 2 AND NOT @XmlEventoErase IS NULL
		BEGIN
			SET @XmlEventoCompress = dbo.compress(CONVERT(VARBINARY(MAX), @XmlEventoErase))
		END

		--Paziente di prova dare precedenza
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
		-- Valido solo  @TipoEventoCodice = A, D, R, X, E (Per la CCH servono anche i T)
		-- Valido solor @TipoRicoveroCodice = 'O', 'D', 'A'
		-- Escludo ricoveri malformati (manca la A p.e.) @RicoveroStatoCodice deve essere diverso da 255
		--
		-- Corretto errore di TipoRicoveroCodice escludo NULL
		-- Ora nella procedura di SANDRO i @TipoRicoveroCodice='' sono esclusi
		-- Ora nella procedura di ETTORE i @TipoRicoveroCodice='' sono inclusi
		-- DA verificare se servono o no, permetto i NULL (Altro controllo in lettura)
		--
		IF [sole].[IsEventoInviabile](@TipoEventoCodice, @TipoRicoveroCodice, @RicoveroStatoCodice, 1) = 1
		BEGIN
			--
			--	Rimuovo dalla coda degli eventi simili al corrente perche' poi sarebbero inviati più volta
			-- a seguiti di cancellazioni e aggiornamenti
			--
			EXEC [sole].[CodaEventiRimuoveDaInviare] @IdEvento, @Operazione, @StatoCodice, @TipoEventoCodice
													,@AziendaErogante, @SistemaErogante, @NumeroNosologico
			--
			-- Aggiungo alla coda SOLE
			--
			INSERT INTO [sole].[CodaEventi]
				([IdEvento], [Operazione], [Sorgente], [AziendaErogante], [SistemaErogante]
				, [TipoEventoCodice], [TipoRicoveroCodice], [DataModificaEvento]
				, [Priorita], [OreRitardoInvio], [Messaggio], [NumeroNosologico])
			VALUES
				(@IdEvento, @Operazione, @Sorgente, @AziendaErogante, @SistemaErogante
				,@TipoEventoCodice, ISNULL(@TipoRicoveroCodice,''), @DataModificaEvento
				,@Priorita, @OreRitardoInvio, @XmlEventoCompress, @NumeroNosologico)

		END
	END
END