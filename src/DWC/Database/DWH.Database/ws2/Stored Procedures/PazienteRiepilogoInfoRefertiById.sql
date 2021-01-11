


CREATE PROCEDURE [ws2].[PazienteRiepilogoInfoRefertiById]
(
	@IdPaziente UNIQUEIDENTIFIER
	, @DatiRefertiDaGiorni INT = NULL --serve a filtrare i referti più vecchi di N giorni
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2PazienteRiepilogoInfoRefertiById
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Uso la vista ws2.Ricoveri, basta onorare solo gli oscuramenti puntuali (FORACCHIA)
	
	Restituisce info referti del paziente		
	Aggiunto il filtro per @DataMinimaReferto anche nella select che restituisce i dati dell'ultimo referto 
	
	MODIFICA ETTORE 2015-07-24: traslazione dell’IdPaziente passato come parametro nell’IdPaziente Attivo
*/
	SET NOCOUNT ON;
	
	DECLARE @DataMinimaReferto DATETIME
	DECLARE @DataPartizioneDal DATETIME
	
	
	BEGIN TRY
		SET @DataMinimaReferto = NULL
		IF NOT @DatiRefertiDaGiorni IS NULL
		BEGIN
			SET @DataMinimaReferto = DATEADD(day, - @DatiRefertiDaGiorni, GETDATE())
			--Prendo solo la parte data
			SET @DataMinimaReferto = CAST(CONVERT(VARCHAR(10), @DataMinimaReferto, 120) AS DATETIME)			
		END
		--
		-- Calcolo la data partizione di filtro (la ottengo da @DataMinimaReferto)
		--
		IF NOT @DataMinimaReferto IS NULL
			SELECT @DataPartizioneDal = dbo.OttieniFiltroRefertiPerDataPartizione(@DataMinimaReferto)
			
		--			
		-- Traslo l'idpaziente nell'idpaziente attivo			
		--
		SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
		--
		-- Lista dei fusi + l'attivo
		--
		DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
		INSERT INTO @TablePazienti(Id)
			SELECT Id
			FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)
			
		--------------------------------------------------------------------------------------
		-- Informazioni statistiche sui referti
		--------------------------------------------------------------------------------------
		-- ATTENZIONE: la vista Referti esclude già i cancellati, gli annullati, i confidenziali e quelli associati a pazienti cancellati
		-- Forse si dovrebbe utilizzare la RefertiTutti che restiruisce il Ruolo e poi dal codice del WS verificare quelli che l'utente può accedere 
		-- Quindi bisogna creare una nuova SP 
		--------------------------------------------------------------------------------------
		DECLARE @NumeroReferti INTEGER
		DECLARE @DataUltimoReferto DATETIME
		DECLARE @AziendaEroganteUltimoReferto AS VARCHAR(16)	
		DECLARE @SistemaEroganteUltimoReferto AS VARCHAR(16)
		--
		-- Ricavo il numero totale dei referti: ho usato questa perchè è la stessa che uso nell'anteprima paziente
		-- attraverso la function che fornisce l'anteprima (quindi viene già chiamata per il front end del DWH nelle
		-- liste paziente). In questo modo ho anche i dati per costruire l'anteprima
		-- In più faccio filtro per DataReferto, cosi diventa simile alla GetRefertoDatamax()
		--		
		SELECT 
			@NumeroReferti = COUNT(*) 
		FROM 
			--Uso ws2.Referti: basta onorare solo oscuramenti puntuali (FORACCHIA)
			ws2.Referti AS R WITH(NOLOCK) 
			INNER JOIN @TablePazienti AS P
				ON  R.IdPaziente = P.Id
		WHERE 
			(@DataMinimaReferto IS NULL OR R.DataReferto >= @DataMinimaReferto)
			--
			-- Filtro per DataPartizione
			--
			AND (R.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
		--
		-- 
		--			
		IF @NumeroReferti > 0 
		BEGIN
			SELECT TOP 1
				@AziendaEroganteUltimoReferto = R.AziendaErogante, 
				@SistemaEroganteUltimoReferto = R.SistemaErogante, 
				@DataUltimoReferto = MAX(R.DataReferto) 
			FROM 
				--Uso ws2.Referti: basta onorare solo oscuramenti puntuali (FORACCHIA)
				ws2.Referti AS R WITH(NOLOCK) 
				INNER JOIN @TablePazienti Pazienti 
					ON R.IdPaziente = Pazienti.Id
			WHERE 
				(@DataMinimaReferto IS NULL OR R.DataReferto >= @DataMinimaReferto)
				--
				-- Filtro per DataPartizione
				--
				AND (R.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
			GROUP BY R.AziendaErogante, R.SistemaErogante
			ORDER BY MAX(R.DataReferto) DESC 
		END
		--
		--
		--
		SELECT 
			@IdPaziente AS IdPaziente
			, @NumeroReferti AS NumeroReferti
			, @DataUltimoReferto AS DataUltimoReferto
			, @AziendaEroganteUltimoReferto AS AziendaEroganteUltimoReferto
			, @SistemaEroganteUltimoReferto AS SistemaEroganteUltimoReferto			
			

	END TRY
	BEGIN CATCH
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()
		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'Ws2PazienteRiepilogoInfoRefertiById. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
	END CATCH
END

