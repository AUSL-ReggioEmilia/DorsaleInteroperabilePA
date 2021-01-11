






-- =============================================
-- Author:		ETTORE
-- Create date: 2016-03-15
-- Description:	Restituisce i referti associati sia al ricovero che alla prenotazione (se @Nosologico è un codice ricovero)
--				Dal ricovero ricavo la data di accettazione ed eventualmente la data di prenotazione per quel ricovero per poter
--				avere una data minima di partizione	
-- Modify date: 2016-09-01 - ETTORE: Verifico che al ruolo sia associato il permesso di bypassare il consenso
-- Modify date: 2017-05-12 - ETTORE: Modificato il significato del parametro @MaxNumRow (ora è il TOP della query sui referti)
--									 Aggiunto gestione dell'oscuramento
-- Modify date: 2017-08-31 - ETTORE: Aggiunto "ORDER BY DataEvento DESC" nella select che popola la tabella temporanea dei referti
--									 per assicurare che vengano restituiti sempre gli ultimi
-- Modify date: 2018-03-15 - ETTORE: Prima il @Top dei referti veniva calcolato erroneamente usando [dbo].[GetConfigurazioneInt] ('Ws_Top','Prestazioni')
--									 Ora si usa [dbo].[GetConfigurazioneInt] ('Ws_Top','Referti')
-- Modify date: 2018-06-11 - ETTORE: Definito un numero massimo di referti da usare per la matrice e si 
--									 restituiscono tutte le prestazioni di quei referti
-- Modify date: 2019-01-18 - ETTORE: Parametro AziendaErogante non è più obbligatorio
-- =============================================
CREATE PROCEDURE ws3.PrestazioniMatriceLabByNosologicoAzienda
(
	@IdToken			UNIQUEIDENTIFIER
	, @MaxNumRow		INTEGER  --Questo deve essere considerato come un TOP sul numero di referti
	, @Ordinamento		VARCHAR(128)
	, @ByPassaConsenso	BIT		
	, @NumeroNosologico VARCHAR(64)
	, @AziendaErogante	VARCHAR(16)
	, @PrestazioneCodice VARCHAR(12)=NULL
	, @SezioneCodice VARCHAR(12)=NULL
)
AS
BEGIN
/*
	Affinchè questa SP restituisce dei referti bisogna che il nosologico esista nella tabella Ricoveri

	ATTENZIONE: il risultato dipende sia dall'intervallo [@DallaDataReferto, @AllaDataReferto] e dalla limitazione sul TOP 
				dei referti che per ora è letto da configurazione ed è al MAX 200
				Se si confrontano due sp (con due script diversi) che dovrebbero dare lo stesso risultato se il numero dei referti è > TOP (=200)
				si possono ottenere risultati differenti nell'elenco dei referti (sono sempre 200 ma alcuni Id differenti) e quindi nell'elenco 
				delle prestazioni
*/
	SET NOCOUNT ON
	DECLARE @Categoria  AS VARCHAR(16)=NULL --Valori possibili: 'Prenotazione', 'Ricovero'

	--
	-- Se @AziendaErogante è vuoto lo imposto a NULL
	--
	IF ISNULL(@AziendaErogante, '') = ''
		SET @AziendaErogante = NULL

	--
	-- Imposto '' per l'ordinamento di default
	--
	SET @Ordinamento = ISNULL(@Ordinamento ,'')
	--
	-- Unico ordinamento permesso
	--	
	IF (@Ordinamento <> '') AND (NOT (@Ordinamento LIKE 'DataEvento%') )
	BEGIN
		RAISERROR('Errore valorizzazione campo @Ordinamento. Valori permessi: DataEvento@ASC, DataEvento@DESC', 16, 1)
		RETURN
	END 
	--
	-- Limitazione records restituiti da database
	-- ATTENZIONE: Ora il DWH-USER passa sempre il valore 1000. Per ora allineo il comportameno della SP a quello dei WS2.
	--			   In seguito modificheremo il DWH-USER per passare come numero max di referti un valore scelto dall'utente
	SELECT @MaxNumRow = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Matrice_Prestazioni','Max_Num_Referti') , 200)      
	--PRINT '@MaxNumRow = ' + CAST(@MaxNumRow AS VARCHAR(10))

	--
	-- Verifico se al token è associato l'attibuto ATTRIB@VIEW_ALL
	--
	DECLARE @ViewAll as BIT=0
	IF EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) where Accesso = 'ATTRIB@VIEW_ALL')
		SET @ViewAll = 1
	--
	-- MODIFICA ETTORE 2016-09-01: Verifico che al ruolo sia associato il permesso di bypassare il consenso
	--
	IF @ByPassaConsenso = 1
	BEGIN
		IF NOT EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) WHERE Accesso = 'ATTRIB@ACCES_NEC_CLIN')
		BEGIN
			DECLARE @Errore NVARCHAR(4000);
			SET @Errore= N'[SecurityError]Il ruolo corrente non ha il permesso di bypassare il consenso.' 
			RAISERROR(@Errore, 16, 1)
			RETURN
		END
	END
	--
	-- Ricavo l'Id del ruolo Role Manager associato al token
	--
	DECLARE @IdRuolo UNIQUEIDENTIFIER 
	SELECT @IdRuolo = IdRuolo FROM dbo.Tokens WHERE Id = @IdToken

	--
	-- Determino se è un ricovero o una prenotazione
	--	
	SELECT
		@Categoria = Categoria
	FROM 
		ws3.Ricoveri
	WHERE 
		(AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
		AND NumeroNosologico = @NumeroNosologico


	--
	-- Memorizzo il parametro @NumeroNosologico nella tabella
	--
	DECLARE @TabNosologici AS TABLE(CodiceNosologico VARCHAR(64))
	INSERT INTO @TabNosologici(CodiceNosologico) VALUES (@NumeroNosologico)
	--
	-- Cerco eventuali nosologici di lista di attesa e li aggiungo alla @TabNosologici 
	--
	--IF dbo.IsNosologicoListaDiAttesa(@NumeroNosologico) = 0 
	IF @Categoria = 'Ricovero' 
	BEGIN
		INSERT INTO @TabNosologici(CodiceNosologico)
		SELECT dbo.GetCodicePrenotazioneByAziendaEroganteCodiceRicovero(NULL, @NumeroNosologico) 
		--dbo.GetCodicePrenotazioneByAziendaEroganteCodiceRicovero restituisce NULL se non trova: cancello i NULL
		DELETE FROM @TabNosologici WHERE CodiceNosologico IS NULL
	END

	--
	-- Ricavo gli IdSac del/dei pazienti e i valori per DallaData e AllaData (associati alla prenotazione o al ricovero) dalla vista ws3.Ricoveri 
	-- Al massimo ci sono 2/3 record: eseguo un DISTINCT
	--
	DECLARE @TabPazienti_Date AS TABLE(IdPaziente UNIQUEIDENTIFIER, DallaData DATETIME, AllaData DATETIME)
	INSERT INTO @TabPazienti_Date(IdPaziente, DallaData, AllaData )
	SELECT DISTINCT
		IdPaziente
		-- Stiamo un po larghi come finestra temporale
		, DATEADD(month, - 1, DataAccettazione) AS DallaData
		-- Le colture di microbiologia possono durare mesi, magari il referto arriva dopo la dimissione
		, DATEADD(month, + 12, DataDimissione) AS AllaData
	FROM ws3.Ricoveri
	WHERE (AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
			AND NumeroNosologico IN (SELECT CodiceNosologico FROM @TabNosologici)

	--
	-- Memorizzo valori minimi e massimi per la data del referto (se c'è una lista di attesa questa è precedente al ricovero)
	--
	DECLARE @DallaDataReferto DATETIME
	DECLARE @AllaDataReferto DATETIME
	SELECT @DallaDataReferto = MIN(DallaData) FROM @TabPazienti_Date
	SELECT @AllaDataReferto = MAX(AllaData) FROM @TabPazienti_Date WHERE NOT AllaData IS NULL

	--
	-- Determino il paziente attivo a partire da un paziente della tabella @TabPazienti_Date (devono appartenere alla stessa catena di fusione)
	--
	DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER 
	SELECT TOP 1 @IdPazienteAttivo = IdPaziente FROM @TabPazienti_Date
	SELECT @IdPazienteAttivo = dbo.GetPazienteAttivoByIdSac(@IdPazienteAttivo)

	--
	-- Calcolo la data partizione di filtro (non deve dipendere dal consenso)
	--
	DECLARE @DallaDataPartizione DATETIME
	SELECT @DallaDataPartizione = dbo.OttieniFiltroRefertiPerDataPartizione(@DallaDataReferto)
	--
	-- Trovo i dati del consenso aziendale del paziente solo se non è stato forzato il consenso
	--
	IF @ByPassaConsenso = 0
	BEGIN 
		SELECT 
			@DallaDataReferto = [dbo].[GetDataMinimaByConsensoAziendale](@DallaDataReferto, ConsensoAziendaleCodice, ConsensoAziendaleData)		
		FROM dbo.Pazienti 
		WHERE Id = @IdPazienteAttivo
	END
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TableAllIdPazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TableAllIdPazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPazienteAttivo)		

	--
	-- Trovo i referti associati al nosologico
	--
	DECLARE @TableReferti as TABLE (Id uniqueidentifier, DataPartizione smalldatetime, AziendaErogante VARCHAR(16)
				, SistemaErogante VARCHAR(16), StrutturaEroganteCodice VARCHAR(64), NumeroNosologico VARCHAR(64)
				, RepartoRichiedenteCodice VARCHAR(64), RepartoErogante VARCHAR(128), Confidenziale BIT)
    INSERT INTO @TableReferti(Id, DataPartizione,AziendaErogante,SistemaErogante
								, StrutturaEroganteCodice, NumeroNosologico, RepartoRichiedenteCodice
								, RepartoErogante, Confidenziale)
    SELECT TOP (@MaxNumRow)
				R.Id, R.DataPartizione, R.AziendaErogante, R.SistemaErogante
				, R.StrutturaEroganteCodice, R.NumeroNosologico, R.RepartoRichiedenteCodice
				, R.RepartoErogante, R.Confidenziale
		FROM ws3.Referti AS R
			INNER JOIN @TableAllIdPazienti AS P
			ON R.IdPaziente = P.Id
	WHERE	
		(R.SistemaErogante = 'LAB') AND				
		(R.StatoRichiestaCodice <> 3) AND	-- Escludo i cancellati
		-- Cerco sia per nosologico del ricovero che nosologico della prenotazione 
		(R.NumeroNosologico IN (SELECT CodiceNosologico FROM @TabNosologici))
		AND (R.DataReferto >= @DallaDataReferto OR @DallaDataReferto IS NULL) 
		AND (R.DataReferto <= @AllaDataReferto OR @AllaDataReferto IS NULL)
		AND (R.DataPartizione >= @DallaDataPartizione OR @DallaDataPartizione IS NULL)
	ORDER BY R.DataEvento DESC --Cosi gli ultimi li restituisco sempre
	--
	-- Ora elimino i referti oscurati applicando il pattern dell'oscuramento per cancellare dalla tabella 
	-- @TableReferti i referti oscurati
	--
	IF @ViewAll <> 1
	BEGIN
			DELETE  @TableReferti
			FROM @TableReferti R
			WHERE  ([dbo].[CheckRefertoOscuramenti] (@IdRuolo, R.Id, R.DataPartizione, R.AziendaErogante, R.SistemaErogante
													, R.StrutturaEroganteCodice, R.NumeroNosologico, R.RepartoRichiedenteCodice
													, R.RepartoErogante, R.Confidenziale ) <> 1)
				OR NOT EXISTS( SELECT * FROM [dbo].[OttieniSistemiErogantiPerToken](@IdToken) SE 
									WHERE   R.SistemaErogante = SE.SistemaErogante AND  R.AziendaErogante = SE.AziendaErogante)
	END

	--
	-- Restituisco i dati
	--
	SELECT	
			RP.IdRefertiBase AS IdReferto,
			RP.DataReferto,
			RP.NumeroReferto,
			RP.AziendaErogante,
			RP.SistemaErogante,
			RP.RepartoErogante,
			RP.IdPrestazioneBase AS IdPrestazione,
			RP.SezioneCodice,
			RP.SezioneDescrizione,
			RP.PrestazioneCodice,
			RP.PrestazioneDescrizione,
			RP.SezionePosizione,
			RP.PrestazionePosizione,
			-----			
			RP.Risultato,			
			--Convert(varchar (255),RP.Quantita) as Quantita,
			RP.Quantita,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'UnitaDiMisuraDescrizione')) as UnitaDiMisuraDescrizione,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'UnitaDiMisuraSistema')) as UnitaDiMisuraSistema,			
			RP.ValoriRiferimento,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'RangeDiNormalitaValoreMinimo')) as RangeDiNormalitaValoreMinimo,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'RangeDiNormalitaValoreMassimo')) as RangeDiNormalitaValoreMassimo,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'RangeDiNormalitaValoreMinimoUDM')) as RangeDiNormalitaValoreMinimoUDM,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'RangeDiNormalitaValoreMassimoUDM')) as RangeDiNormalitaValoreMassimoUDM,
			RP.Commenti,			
			RP.DataEvento,
			RP.Firmato
	FROM		
			-------------------------------------------------
			-- Ho già calcolato gli Id referto validi filtro solo sui campi delle Prestazioni di 
			-- store.RefertiPrestazioni
			-------------------------------------------------
			store.RefertiPrestazioni AS RP
			INNER JOIN @TableReferti FiltroReferti
                ON RP.IdRefertiBase = FiltroReferti.Id
	WHERE	
		--Escludo ciò che è di batteriologia
		CAST(ISNULL(dbo.GetPrestazioniAttributo(RP.IdPrestazioneBase, RP.DataPartizione, 'PrestTipo'),'C') as varchar(10)) <> 'M'
		-- Filtro per @PrestazioneCodice e @SezioneCodice
		AND (RP.PrestazioneCodice = @PrestazioneCodice OR @PrestazioneCodice IS NULL)
		AND (RP.SezioneCodice = @SezioneCodice OR @SezioneCodice IS NULL)
		--
		-- Filtro in base alla data referto e alla data di partizione
		--
		AND (RP.DataEvento>= @DallaDataReferto OR @DallaDataReferto IS NULL) 
		AND (RP.DataEvento <= @AllaDataReferto OR @AllaDataReferto IS NULL)
		AND (RP.DataPartizione >= @DallaDataPartizione OR @DallaDataPartizione IS NULL) 
		
	ORDER BY 
	CASE @Ordinamento  WHEN '' THEN RP.DataEvento END DESC
	, CASE @Ordinamento  WHEN '' THEN RP.NumeroReferto END DESC
	--Ascendente	
	, CASE @Ordinamento  WHEN 'DataEvento@ASC' THEN RP.DataEvento END ASC
	, CASE @Ordinamento  WHEN 'DataEvento@ASC' THEN RP.NumeroReferto END ASC
    --Discendente	
	, CASE @Ordinamento  WHEN 'DataEvento@DESC' THEN RP.DataEvento END DESC
	, CASE @Ordinamento  WHEN 'DataEvento@DESC' THEN RP.NumeroReferto END DESC
			

END