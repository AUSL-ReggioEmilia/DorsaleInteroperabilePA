

-- =============================================
-- Author:		Simone Bitti.
-- Create date: 2017-03-09
-- Description:	Cancellazione Ricoveri e eventi
-- Modify date: 2017-12-28: ETTORE: Notifica in coda output standard
--									In caso di ricovero viene creato evento di erase
--									In caso di prenotazione viene creato evento ML con stato ANNULLATO
--									Si deve notificare anche a SOLE (solo gli eventi che sono RICOVERI, le PRENOTAZIONI no!!!)
-- Modify date: 2019-01-15 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaEventiAggiungi])
--									Invertito ordine notifiche/cancellazione
-- Modify date: 2019-02-25 - SANDRO - Aggiunto @StatoCodice a EXEC [sole].[CodaEventiAggiungi]
-- Modify date: 2020-02-19 - SANDRO - Errore usa dbo.SoleOttieneEventoXml (obsoleta) invece di [sole].[OttieneEventoXml]

-- =============================================
CREATE PROCEDURE [dbo].[BevsCancellaRicovero]
(
	 @Id UNIQUEIDENTIFIER
)
AS
BEGIN	
	SET NOCOUNT ON;
	DECLARE @AziendaErogante VARCHAR(16)
	DECLARE @NumeroNosologico VARCHAR(64)
	DECLARE @SistemaErogante AS VARCHAR(16)
	DECLARE @IdEventoIniziale UNIQUEIDENTIFIER
	DECLARE @TipoEventoInizialeCodice VARCHAR(16)
	DECLARE @IdCorrelazione AS VARCHAR(64)
	DECLARE @TimeoutCorrelazione INT
	--
	-- Ricavo AziendaErogante e NumeroNosologico dal ricovero
	--	
	SELECT @AziendaErogante = AziendaErogante
		, @NumeroNosologico = NumeroNosologico
	FROM [store].[RicoveriBase]
	WHERE id= @Id
	--
	-- SE IL RICOVERO NON ESISTE ESCO.
	--
	IF @NumeroNosologico IS NULL
	BEGIN
		RETURN 
	END
	--
	-- Ricavo l'evento iniziale del nosologico
	--
	SELECT TOP 1 
		  @IdEventoIniziale = Id
		, @SistemaERogante = SistemaErogante
		, @TipoEventoInizialeCodice = TipoEventoCodice
	FROM [store].[EventiBase]
	WHERE TipoEventoCodice IN ('A', 'IL')
		AND AziendaErogante = @AziendaErogante
		AND NumeroNosologico = @NumeroNosologico
	ORDER BY DataModificaEsterno ASC --nell'ordine in cui sono entrati
	--
	-- Verifico che esista l'evento iniziale
	--
	IF @IdEventoIniziale IS NULL
	BEGIN
		DECLARE @ErroMsg AS VARCHAR(200)
		SET @ErroMsg = 'Il ricovero [' +  @AziendaErogante + ', ' + @NumeroNosologico + ']  non ha l''evento iniziale A o IL'
		RAISERROR(@ErroMsg, 16, 1)
		RETURN
	END
	--
	-- Valorizzo il timeout di correlazione e l'IdCorrelazione
	--
	SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput',	'TimeoutCorrelazione'), 1)
	SELECT @IdCorrelazione = [dbo].[GetCodaEventiOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante,  @NumeroNosologico)
	--
	-- Inizializzo le variabili da usere per il messaggio XML di annullamento
	--
	DECLARE @XmlEventoAnnullamento AS XML 
	DECLARE @XmlEventoAnnullamentoSole AS XML 

	DECLARE @IdEventoAnnullamento UNIQUEIDENTIFIER = NEWID()
	DECLARE @IdEventoAnnullamentoSole UNIQUEIDENTIFIER = NEWID()

	IF @TipoEventoInizialeCodice = 'A' --Allora il nosologico è di un RICOVERO
	BEGIN
		--
		-- Creo l'evento di annullamento per RICOVERO
		--
		SELECT @XmlEventoAnnullamento  = [dbo].[CreaEventoAnnullamentoRicovero] (dbo.GetEventoXml2(@IdEventoIniziale), @IdEventoAnnullamento, 'X', 'Annullamento')
		SELECT @XmlEventoAnnullamentoSole  = [dbo].[CreaEventoAnnullamentoRicovero] (sole.OttieneEventoXml(@IdEventoIniziale), @IdEventoAnnullamentoSole, 'X', 'Annullamento')
	END
	ELSE IF @TipoEventoInizialeCodice = 'IL' ----Allora il nosologico è di una PRENOTAZIONE
	BEGIN
		--
		-- Creo l'evento di annullamento per PRENOTAZIONE
		--
		SELECT @XmlEventoAnnullamento  = [dbo].[CreaEventoAnnullamentoPrenotazione] (dbo.GetEventoXml2(@IdEventoIniziale), @IdEventoAnnullamento)
	END

	BEGIN TRANSACTION 
	BEGIN TRY
		--------------------------------------------------------------------
		-- Prima inserisco nella CODA
		--------------------------------------------------------------------

		-------------------------------------------------------------------
		-- Inserisco la notifica dell'evento di Annullamento nella coda output standard
		--
		INSERT INTO CodaEventiOutput (IdEvento, Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
		VALUES(@IdEventoAnnullamento, 1 , @IdCorrelazione, @TimeoutCorrelazione, 0, @XmlEventoAnnullamento)


		-------------------------------------------------------------------
		-- Inserisco la notifica dell'evento di Annullamento nella coda SOLE
		--
		IF @TipoEventoInizialeCodice = 'A' ----Allora il nosologico è di un RICOVERO
		BEGIN
			--
			-- Data evento come ultimo, ordine considera anche IdSequenza
			--
			DECLARE @DataModificaMax DATETIME
			SELECT @DataModificaMax = MAX(DataModifica) FROM [store].[EventiBase]
			WHERE AziendaErogante = @AziendaErogante
					AND NumeroNosologico = @NumeroNosologico
			--
			-- Eseguo l'inserimento nella tabella di coda SOLE
			--	2019-01-16
			--Operazione tipo 2
			EXEC [sole].[CodaEventiAggiungi] @IdEventoAnnullamentoSole, 2, 'DAE', @AziendaErogante, @SistemaErogante, 0
											, 'X', @DataModificaMax, @NumeroNosologico, @XmlEventoAnnullamentoSole
		END

		--------------------------------------------------------------------
		-- Poi cancello dal database
		--------------------------------------------------------------------

		--
		-- Cancello Attributi degli eventi
		--
		DELETE FROM store.EventiAttributi WHERE IdEventiBase IN (
			SELECT id FROM store.EventiBase 
			WHERE AziendaErogante = @AziendaErogante
					AND NumeroNosologico = @NumeroNosologico
					)
		--
		-- Cancello EventiBase
		--
		DELETE FROM store.EventiBase 
		WHERE AziendaErogante = @AziendaErogante
				AND NumeroNosologico = @NumeroNosologico
		--
		-- Cancello RicoveriAttributi
		--
		DELETE FROM store.RicoveriAttributi WHERE IdRicoveriBase IN (
			SELECT id FROM store.RicoveriBase 
			WHERE AziendaErogante = @AziendaErogante
					AND NumeroNosologico = @NumeroNosologico
			)
		--
		-- Cancello Ricovero
		--
		DELETE FROM store.RicoveriBase
			WHERE AziendaErogante = @AziendaErogante
					AND NumeroNosologico = @NumeroNosologico
		--
		-- COMMIT
		--
		COMMIT 
		
		PRINT 'BevsCancellaRicoveri: cancellato il ricovero: ' + @AziendaErogante + '-' + @NumeroNosologico
		
	END TRY		
	BEGIN CATCH
		--
		-- Raise dell'errore + ROLLBACK
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		IF @@TRANCOUNT > 0 ROLLBACK
		
		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BevsCancellaRicoveri. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		PRINT @report;			
	
	END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsCancellaRicovero] TO [ExecuteFrontEnd]
    AS [dbo];

