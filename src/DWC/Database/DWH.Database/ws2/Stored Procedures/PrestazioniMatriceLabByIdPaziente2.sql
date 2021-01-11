




CREATE PROCEDURE [ws2].[PrestazioniMatriceLabByIdPaziente2]
(
	@IdPaziente as uniqueidentifier, 
	@DataRefertoDal as datetime=null, 
	@DataRefertoAl as datetime=null,
	@IdRuolo UNIQUEIDENTIFIER=null
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2PrestazioniMatriceLabByIdPaziente2
		Aggiunto calcolo filtro per data partizione e filtro per data partizione
		Usato i campi della vista store.Prestazioni al posto delle funzioni dbo.GetAttributo()
		Uso della vista ws2.Referti che restituisce il campo Oscuramenti (XML) e della vista store.Prestazioni (che non è filtrata)
		Restituito il campo XML Oscuramenti
		Aggiunto il campo AziendaErogante
		
	Restituisce i dati relativi alle prestazioni di LABORATORIO		

	Differenze dalla Ws2PrestazioniMatriceLabByIdPaziente:
		1) Viene restituito SezioneDescrizione puro senza concatenamento con SezioneCodice
		2) Non viene restituita la data del referto in formato italiano
		3) Non viene restituito Commenti se Risultato è vuoto
		4) Aggiunto i campi Quantita, UnitaDiMisuraDescrizione, UnitaDiMisuraSistema, ValoriRiferimento
		   RangeDiNormalitaValoreMinimo, RangeDiNormalitaValoreMassimo, RangeDiNormalitaValoreMinimoUDM, RangeDiNormalitaValoreMassimoUDM

	Restituisco i campi DataEvento e Firmato
	Si filtra e si ordina su DataReferto	
	
	MODIFICA ETTORE 2015-07-24: traslazione dell’IdPaziente passato come parametro nell’IdPaziente Attivo
	MODIFICA ETTORE 2016-07-04: utilizzo della DataEvento per filtrare e ordinare
	MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
	MODIFICA ETTORE 2018-03-15: Calcolo dinamicamente il numero massimo di referti e di questi restituisco tutte le prestazioni
								Prima si usava la vista frontend.Referti. Ora uso ws2.Referti
	MODIFICA ETTORE 2018-06-05: Aggiunto "ORDER BY DataEvento DESC" nella select che popola la tabella temporanea dei referti
								per assicurare che vengano restituiti sempre gli ultimi
	MODIFICA ETTORE 2018-06-11:	Definito un numero massimo di referti da usare per la matrice e si 
								restituiscono tutte le prestazioni di quei referti

*/

	SET NOCOUNT ON

	--
	-- Ricavo eventualmente la data minima dalle configurazioni
	--
	IF @DataRefertoDal IS NULL
	BEGIN 
		SET @DataRefertoDal = DATEADD(day, - ISNULL([dbo].[GetConfigurazioneInt] ('Ws2','RefertiDaGiorni') , 3650), GETDATE())
	END 
	--
	-- Calcolo la data partizione di filtro
	--
	DECLARE @DataPartizioneDal DATETIME
	SELECT @DataPartizioneDal = dbo.OttieniFiltroRefertiPerDataPartizione(@DataRefertoDal)
	--			
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)

	----------------------------------------------------------------------------------------------
	-- MODIFICA ETTORE 2017-10-10: Gestione filtro basato sul consenso 
	----------------------------------------------------------------------------------------------
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
	-- Se non posso bypassare il consenso applico il filtro in base al consenso associato al paziente
	--
	IF @ByPassaConsenso = 0
	BEGIN 
		SELECT 
			@DataRefertoDal = [dbo].[GetDataMinimaByConsensoAziendale](@DataRefertoDal, ConsensoAziendaleCodice, ConsensoAziendaleData)		
		FROM dbo.Pazienti 
		WHERE Id = @IdPaziente
	END	

	--MODIFICA ETTORE 2018-06-11: leggo dalla coinfigurazione il numero massimo di referti da processare
	DECLARE @MaxNumReferti INTEGER = 0
	SELECT @MaxNumReferti = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Matrice_Prestazioni','Max_Num_Referti') , 200)      
	--PRINT '@MaxNumReferti = ' + CAST(@MaxNumReferti AS VARCHAR(10))		

	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)	


	--
	-- Leggo i referti
	--
	DECLARE @TableReferti as TABLE (Id uniqueidentifier, Oscuramenti XML)
    INSERT INTO @TableReferti(Id, Oscuramenti)
    SELECT TOP (@MaxNumReferti) 
		R.Id, R.Oscuramenti
	FROM 
		ws2.Referti AS R
		INNER JOIN @TablePazienti Pazienti
			ON R.IdPaziente = Pazienti.Id
	WHERE	
		-- Filtro per DataPartizione
		(R.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL) AND
		(R.SistemaErogante = 'LAB') AND 	
		(R.StatoRichiestaCodice <> 3) AND			
		(R.DataEvento >= @DataRefertoDal or @DataRefertoDal is null) AND
		(R.DataEvento <= @DataRefertoAl or @DataRefertoAl is null)
	ORDER BY R.DataEvento DESC --Cosi gli ultimi li restituisco sempre			
	--
	-- Restituisco tutte le prestazioni dei referti 
	--
	SELECT	
			RP.IdRefertiBase,
			RP.DataReferto,
			RP.NumeroReferto,
			RP.AziendaErogante,
			RP.SistemaErogante,
			RP.RepartoErogante,
			RP.IdPrestazioneBase AS IdPrestazioni,
			RP.SezioneCodice,		
			RP.SezioneDescrizione,	
			RP.PrestazioneCodice,
			RP.PrestazioneDescrizione,
			RP.SezionePosizione,
			RP.PrestazionePosizione,
			-----			
			RP.Risultato,			
			Convert(varchar (255),RP.Quantita) as Quantita,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'UnitaDiMisuraDescrizione')) as UnitaDiMisuraDescrizione,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'UnitaDiMisuraSistema')) as UnitaDiMisuraSistema,
			RP.ValoriRiferimento,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'RangeDiNormalitaValoreMinimo')) as RangeDiNormalitaValoreMinimo,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'RangeDiNormalitaValoreMassimo')) as RangeDiNormalitaValoreMassimo,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'RangeDiNormalitaValoreMinimoUDM')) as RangeDiNormalitaValoreMinimoUDM,
			Convert(varchar (255),dbo.GetPrestazioniAttributo( RP.IdPrestazioneBase, RP.DataPartizione, 'RangeDiNormalitaValoreMassimoUDM')) as RangeDiNormalitaValoreMassimoUDM,
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
			--
			-- Lascio Filtro per DataPartizione
			--
			(RP.DataPartizione > @DataPartizioneDal OR @DataPartizioneDal IS NULL)
			--Escludo ciò che è di batteriologia
			AND CAST(ISNULL(dbo.GetPrestazioniAttributo(RP.IdPrestazioneBase, RP.DataPartizione, 'PrestTipo'),'C') as varchar(10)) <> 'M'
			--Questo rende lenta la query, ma è inutile			
			--AND (NOT Prest.Risultato IS NULL or Prest.Risultato <> '' or NOT Prest.Commenti IS NULL or Prest.Commenti <> '') AND
	ORDER BY 	
			RP.DataEvento Desc, 
			RP.NumeroReferto Desc

END




