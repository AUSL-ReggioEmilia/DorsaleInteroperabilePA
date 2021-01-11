






-- =============================================
-- Author:		ETTORE
-- Create date: 2015-05-22
-- Description:	Restituisce le prestazioni associate ad un nosologico e alla sua lista di attesa
-- Modify date: 2016-07-04 - ETTORE: utilizzo della DataEvento per filtrare e ordinare
-- Modify date: 2017-10-10 - ETTORE: Gestione filtro basato sul consenso 
--									 Ricavo @DataDal su cui basare il filtro del consenso dai nosologici
-- Modify date: 2018-03-15 - ETTORE: Uso Ws2.referti al posto di frontend.referti e Ws2.Ricoveri al posto di ws3.ricoveri
--									 Il @MaxNumRow è il numero max di referti su cui andare a leggere le prestazioni
--									 Si cerca tutti i referti del nosologico (al max @MaxNumRow) e si restituiscono tutte le prestazioni
-- Modify date: 2018-06-05 - ETTORE: Aggiunto "ORDER BY DataEvento DESC" nella select che popola la tabella temporanea dei referti
--									 per assicurare che vengano restituiti sempre gli ultimi
-- Modify date: 2018-06-11 - ETTORE: Definito un numero massimo di referti da usare per la matrice e si 
--									 restituiscono tutte le prestazioni di quei referti
-- Modify date: 2019-01-10 - ETTORE: Il parametro @AziendaErogante NON è più obbligatorio
-- =============================================
CREATE PROCEDURE ws2.PrestazioniMatriceLabByNosologicoAzienda
(
	@NumeroNosologico as varchar(64),
	@AziendaErogante as varchar(16),
	@IdRuolo UNIQUEIDENTIFIER=null
)
AS
BEGIN
/*
	Sostituisce la dbo.Ws2PrestazioniMatriceLabByNosologicoAzienda
	Restituito il campo XML Oscuramenti
	Aggiunto il campo AziendaErogante
	Uso le viste ws2.Referti e store.Prestazioni

	Affinchè questa SP restituisce dei referti
	bisogna che il nosologico esista negli Eventi ADT di ricovero o nella tabella Ricoveri

	Traslo l'idpaziente nell'idpaziente attivo			
	Limitazione record restituiti - l'order by era già presente
	Restituisco i referti associati sia al ricovero che alla prenotazione se @Nosologico è un codice ricovero	
	Restituisco i campi DataEvento e Firmato
	Si filtra e si ordina su DataReferto
	Uso nuova funzione dbo.IsNosologicoListaDiAttesa() per capire se il numero nosologico è di una lista di attesa

*/
	SET NOCOUNT ON
	DECLARE @DallaDataReferto DATETIME
	DECLARE @AllaDataReferto DATETIME

	--
	-- Se @AziendaErogante è vuoto lo imposto a NULL
	--
	IF ISNULL(@AziendaErogante, '') = ''
		SET @AziendaErogante = NULL

	--
	-- Limitazione record restituiti
	-- MODIFICA ETTORE 2018-06-11: Ora uso nuova configurazione dedicata al massimo numero di referti da processare per la matrice delle prestazioni
	DECLARE @MaxNumReferti INTEGER
	SELECT @MaxNumReferti = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Matrice_Prestazioni','Max_Num_Referti') , 200)      

	--
	-- Memorizzo il parametro @NumeroNosologico nella tabella
	--
	DECLARE @TabNosologici AS TABLE(CodiceNosologico VARCHAR(64))
	INSERT INTO @TabNosologici(CodiceNosologico) VALUES (@NumeroNosologico)
	--
	-- Cerco eventuali nosologici di lista di attesa e li aggiungo alla @TabNosologici 
	--
	IF dbo.IsNosologicoListaDiAttesa(@NumeroNosologico) = 0 
	BEGIN
		INSERT INTO @TabNosologici(CodiceNosologico)
		SELECT dbo.GetCodicePrenotazioneByAziendaEroganteCodiceRicovero(NULL, @NumeroNosologico) 
		--dbo.GetCodicePrenotazioneByAziendaEroganteCodiceRicovero restituisce NULL se non trova: cancello i NULL
		DELETE FROM @TabNosologici WHERE CodiceNosologico IS NULL
	END

	--
	-- Cerco eventuale attributo di bypass del consenso associato al ruolo
	-- 
	DECLARE @ByPassaConsenso BIT = 0
	IF @IdRuolo IS NULL
	BEGIN
		SET @ByPassaConsenso = 1
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT * FROM [dbo].[SAC_RuoliAccesso] WHERE (IdRuolo = @IdRuolo AND Accesso = 'ATTRIB@ACCES_NEC_CLIN'))
			SET @ByPassaConsenso = 1
	END

	--
	-- Ricavo gli IdSac del/dei pazienti e i valori per DallaData e AllaData (associati alla prenotazione o al ricovero) dalla vista ws2.Ricoveri 
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
	FROM ws2.Ricoveri
	WHERE (AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
			AND NumeroNosologico IN (SELECT CodiceNosologico FROM @TabNosologici)

	--
	-- Memorizzo valori minimi e massimi (se c'è una lista di attesa questa è precedente al ricovero)
	--
	SELECT @DallaDataReferto = MIN(DallaData) FROM @TabPazienti_Date
	SELECT @AllaDataReferto = MAX(AllaData) FROM @TabPazienti_Date WHERE NOT AllaData IS NULL

	--
	-- Determino il paziente attivo a partire da un paziente  della tabella @TabPazienti_Date (devono appartenere alla stessa catena di fusione)
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
	-- Se non posso bypassare il consenso applico il filtro in base al consenso associato al paziente
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
	-- Leggo i referti TOP (@MaxNumReferti)
	--
	DECLARE @TableReferti as TABLE (Id uniqueidentifier, Oscuramenti XML)
    INSERT INTO @TableReferti(Id, Oscuramenti)
    SELECT TOP (@MaxNumReferti)
		R.Id, R.Oscuramenti
	FROM 
		ws2.Referti AS R
		INNER JOIN @TableAllIdPazienti Pazienti
			ON R.IdPaziente = Pazienti.Id
	WHERE	
		(R.SistemaErogante = 'LAB') AND				
		(R.StatoRichiestaCodice <> 3) AND		-- Escludo i cancellati
		(
			R.NumeroNosologico IN (SELECT CodiceNosologico FROM @TabNosologici)
		)
		AND (R.DataReferto >= @DallaDataReferto OR @DallaDataReferto IS NULL) 
		AND (R.DataReferto <= @AllaDataReferto OR @AllaDataReferto IS NULL)
		AND (R.DataPartizione >= @DallaDataPartizione OR @DallaDataPartizione IS NULL)
	ORDER BY R.DataEvento DESC --Cosi gli ultimi li restituisco sempre
	--
	-- Restituisco tutte le prestazioni
	--
	SELECT	
			RP.IdRefertiBase,
			RP.DataReferto,
			RP.NumeroReferto,
			Convert(VarChar(20), RP.DataReferto, 103) AS DataRefertoItaliano,
			RP.AziendaErogante,
			RP.SistemaErogante,
			RP.RepartoErogante,
			RP.IdPrestazioneBase AS IdPrestazioni,
			RP.SezioneCodice,
			LTRIM(RTRIM(RP.SezioneDescrizione)) + ' (' + RP.SezioneCodice + ')' as SezioneDescrizione,
			RP.PrestazioneCodice,
			RP.PrestazioneDescrizione,
			COALESCE( NULLIF(RP.Risultato, ''), RP.Commenti) AS Risultato,
			RP.SezionePosizione,
			RP.PrestazionePosizione,
			RP.Commenti,
			RP.DataEvento,
			RP.Firmato,
			FiltroReferti.Oscuramenti
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
			--Questo rende lenta la query, ma è inutile
			--(NOT RP.Risultato IS NULL or RP.Risultato <> '' or NOT RP.Commenti IS NULL or RP.Commenti <> '') AND
			
	ORDER BY 	
			RP.DataEvento Desc, 
			RP.NumeroReferto Desc
		
END



