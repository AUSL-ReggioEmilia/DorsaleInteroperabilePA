









-- =============================================
-- Author:		ETTORE
-- Create date: 2020-03-10
-- Description:	Crea Evento LA a partire dall'evento A
--				Usata nella gestione delle liste di attesa di HERO
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiListaAttesaCreaEventoLA]
(	
	@IdEvento UNIQUEIDENTIFIER				--dati di testata dell'evento A
	, @DataPartizione SMALLDATETIME
	, @IdPaziente UNIQUEIDENTIFIER
	, @AziendaErogante VARCHAR(16)
	, @SistemaErogante VARCHAR(16)
	, @RepartoErogante VARCHAR(64)
	, @DataEvento DATETIME
	, @TipoEpisodio VARCHAR(16)
	, @RepartoCodice VARCHAR(16)
	, @RepartoDescr  VARCHAR(128)
	, @Diagnosi  VARCHAR(1024)
	, @NumeroNosologico VARCHAR(64)			--nosologico dell'evento A
	, @NosologicoPrenotazione VARCHAR(64)	--nosologico della prenotazione associata
)
AS 
BEGIN

	DECLARE @TempTAB_IdEventiLA TABLE (IdEventiBase UNIQUEIDENTIFIER, DataPartizione SMALLDATETIME)

	BEGIN TRANSACTION
	BEGIN TRY
		--------------------------------------------------------------------------------------------------------
		-- Cancellazione eventuali record Eventi di tipo LA associati a questo ricovero
		--------------------------------------------------------------------------------------------------------
		--
		-- Carico una tabella temporanea per disaccoppiare l'operazione di DELETE dalla lettura
		--
		INSERT INTO @TempTAB_IdEventiLA(IdEventiBase, DataPartizione)
		SELECT Id, DataPartizione FROM store.EventiBase 
		WHERE 
			AziendaErogante = @AziendaErogante
			AND NumeroNosologico = @NumeroNosologico --nosologico del ricovero
			AND TipoEventoCodice = 'LA' 
	
		--
		-- Cancello gli attributi di tutti i record LA associati al ricovero
		--
		DELETE EA
		FROM store.EventiAttributi AS EA
			INNER JOIN @TempTAB_IdEventiLA AS TEMP
				ON EA.IdEventiBase = TEMP.IdEventiBase
					AND EA.DataPartizione = TEMP.DataPartizione 
		--
		-- Cancello tutte le testate di tutti i record LA associati al ricovero
		--
		DELETE EB
			FROM store.EventiBase AS EB
			INNER JOIN @TempTAB_IdEventiLA AS TEMP
				ON EB.Id = TEMP.IdEventiBase
					AND EB.DataPartizione = TEMP.DataPartizione 
		--------------------------------------------------------------------------------------------------------
		-- FINE Cancellazione eventuali record Eventi di tipo LA associati a questo ricovero
		--------------------------------------------------------------------------------------------------------

		IF ISNULL(@NosologicoPrenotazione, '') <> ''
		BEGIN 
			--------------------------------------------------------------------------------------------------------
			-- Costruisco l'IdEsterno dell'evento LA
			--------------------------------------------------------------------------------------------------------
			DECLARE @IdEsternoEventoLA VARCHAR(64)
			DECLARE @DataModificaEsternoLA DATETIME = GETDATE() -- Non ho la DataModificaEsterna del ricovero, viene impostata da DAE
			SET @IdEsternoEventoLA = @AziendaErogante + '_' + @SistemaErogante + '_' + @NosologicoPrenotazione 
								+  REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(40), @DataModificaEsternoLA, 120),'-',''), ' ', ''), ':',''), '.', '') 
								+ '_LA'

			--------------------------------------------------------------------------------------------------------
			-- Creazione evento fittizio LA
			--------------------------------------------------------------------------------------------------------
			--
			-- Inserisco la testata dell'evento fittizio LA
			--
			DECLARE @IdEventoLA_NEW UNIQUEIDENTIFIER
			DECLARE @StatoCodiceLA INT
			SET @IdEventoLA_NEW = NEWID()
			SET @StatoCodiceLA = 0 --Lo imposto sempre VISIBILE
			INSERT INTO store.EventiBase
				(	
				Id, IdEsterno, DataModificaEsterno, IdPaziente, DataInserimento, DataModifica, AziendaErogante, SistemaErogante, RepartoErogante
				, DataEvento, StatoCodice, TipoEventoCodice, TipoEventoDescr, NumeroNosologico,TipoEpisodio, RepartoCodice, RepartoDescr
				, Diagnosi, DataPartizione)
			VALUES
				(
				@IdEventoLA_NEW, @IdEsternoEventoLA, @DataModificaEsternoLA , @IdPaziente,	GETDATE(), GETDATE(), @AziendaErogante, @SistemaErogante, @RepartoErogante
				, @DataEvento, @StatoCodiceLA, 'LA', '', @NumeroNosologico, @TipoEpisodio, @RepartoCodice, @RepartoDescr
				, @Diagnosi, @DataPartizione
				)	
			---
			-- Inserisco gli attributi per l'evento fittizio LA
			-- Attributi Anagrafici + il numero nosologico della lista di attesa
			-- Gli Attributi Anagrafici li leggo dagli attributi appena inseriti per l'evento corrente
			-- Carico prima una tabella temporanea per disaccoppiare l'inserimento dalla lettura degli attributi
			--
			DECLARE @TempTab_AttributiEventoLA TABLE (IdEventiBase UNIQUEIDENTIFIER, Nome VARCHAR(64), Valore SQL_VARIANT, DataPartizione SMALLDATETIME)
			INSERT INTO @TempTab_AttributiEventoLA (IdEventiBase, Nome,  Valore, DataPartizione) 
			SELECT @IdEventoLA_NEW, Nome,  Valore, DataPartizione
			FROM store.EventiAttributi 
			WHERE 
				IdEventiBase = @IdEvento AND DataPartizione = @DataPartizione
				AND Nome IN ('CodiceAnagraficaCentrale','NomeAnagraficaCentrale','Cognome','Nome','Sesso'
							,'DataNascita','ComuneNascita','CodiceFiscale','CodiceSanitario','IdEsternoPaziente'
							)
			UNION
			SELECT @IdEventoLA_NEW, 'CodiceListaAttesa',  LTRIM(RTRIM(@NosologicoPrenotazione)), @DataPartizione
	
			--
			-- Inserisco gli attributi dell'evento LA
			--
			INSERT INTO store.EventiAttributi (IdEventiBase, Nome,  Valore, DataPartizione) 
			SELECT IdEventiBase, Nome,  Valore, DataPartizione FROM @TempTab_AttributiEventoLA 
			--------------------------------------------------------------------------------------------------------
			-- FINE: Creazione evento fittizio LA
			--------------------------------------------------------------------------------------------------------
		END 

		--
		-- COMMIT
		--
		COMMIT

		RETURN 0
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
		SELECT @report = N'ExtEventiCreaEventoLADaEventoA. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		RETURN 1
	END CATCH
END