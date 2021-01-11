


-- =============================================
-- Author:		ETTORE
-- Create date: 2015-05-22
-- Description:	Restituisce i dati relativi alle prestazioni di LABORATORIO		
--				Uso della vista ws3.Referti che restituisce il campo Oscuramenti (XML) e della vista store.Prestazioni (che non è filtrata)
--				NOVITA': Permetto solo ordinamento sul campo DataEvento, altrimenti segnalazione di errore.
-- Modify Date: 2016-09-01 - ETTORE: Verifico che al ruolo sia associato il permesso di bypassare il consenso
-- Modify Date: 2017-05-16 - ETTORE: 
--						Modificato il significato del parametro @MaxNumRow (ora è il TOP della query sui referti)
--						Aggiunto gestione dell'oscuramento 
--						Ricalcolo dinamico del @MaxNumRow
-- Modify Date: 2017-08-31 - ETTORE: 
--						Aggiunto "ORDER BY DataEvento DESC" nella select che popola la tabella temporanea dei referti
--						per assicurare che vengano restituiti sempre gli ultimi
-- Modify Date: 2018-01-30 - ETTORE: 
--						A causa del controllo sul consenso @MaxNumRow può diventare negativo quando il paziente 
--						non ha dato il consenso e non è stato passato @ByPassaConsenso=1
-- Modify Date: 2018-06-11 - ETTORE: Definito un numero massimo di referti da usare per la matrice e si 
--						restituiscono tutte le prestazioni di quei referti
-- =============================================
CREATE PROCEDURE [ws3].[PrestazioniMatriceLabByIdPaziente]
(
	@IdToken			UNIQUEIDENTIFIER
	, @MaxNumRow		INTEGER    --Questo deve essere considerato come un TOP sul numero di referti
	, @Ordinamento		VARCHAR(128)
	, @ByPassaConsenso	BIT		
	, @IdPaziente		UNIQUEIDENTIFIER
	, @DallaDataReferto	DATETIME=NULL
	, @AllaDataReferto	DATETIME=NULL
	, @PrestazioneCodice VARCHAR(12)=NULL
	, @SezioneCodice VARCHAR(12)=NULL
) WITH RECOMPILE
AS
BEGIN
		SET NOCOUNT ON
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
		-- Traslo l'idpaziente nell'idpaziente attivo                
		--
		SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
       
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
				WHERE Id = @IdPaziente
		END
		--
		-- Limitazione records restituiti da database
		-- ATTENZIONE: Ora il DWH-USER passa sempre il valore 1000. Per ora allineo il comportameno della SP a quello dei WS2.
		--			   In seguito modificheremo il DWH-USER per passare come numero max di referti un valore scelto dall'utente
		SELECT @MaxNumRow = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Matrice_Prestazioni','Max_Num_Referti') , 200)      
		--PRINT '@MaxNumRow = ' + CAST(@MaxNumRow AS VARCHAR(10))

		--
		-- Lista dei fusi + l'attivo
		--
		DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
		INSERT INTO @TablePazienti(Id)
				SELECT Id
				FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)     
             
		DECLARE @TableReferti as TABLE (Id uniqueidentifier, DataPartizione smalldatetime, AziendaErogante VARCHAR(16)
						, SistemaErogante VARCHAR(16), StrutturaEroganteCodice VARCHAR(64), NumeroNosologico VARCHAR(64)
						, RepartoRichiedenteCodice VARCHAR(64), RepartoErogante VARCHAR(128), Confidenziale BIT)
		--
		-- Trovo tutti i referti del paziente nel periodo considerato
		--
		INSERT INTO @TableReferti(Id, DataPartizione,AziendaErogante,SistemaErogante
								, StrutturaEroganteCodice, NumeroNosologico, RepartoRichiedenteCodice
								, RepartoErogante, Confidenziale)
		SELECT TOP (@MaxNumRow)
				R.Id, R.DataPartizione, R.AziendaErogante, R.SistemaErogante
				, R.StrutturaEroganteCodice, R.NumeroNosologico, R.RepartoRichiedenteCodice
				, R.RepartoErogante, R.Confidenziale
		FROM ws3.Referti AS R
					INNER JOIN @TablePazienti Pazienti
					ON R.IdPaziente = Pazienti.Id
		WHERE  
				(R.SistemaErogante = 'LAB') 
				AND (R.StatoRichiestaCodice <> 3) 
				--
				-- Filtro in base alla data referto e alla data di partizione
				--
				AND (R.DataReferto >= @DallaDataReferto OR @DallaDataReferto IS NULL) AND (R.DataReferto <= @AllaDataReferto OR @AllaDataReferto IS NULL)
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
				AND (RP.DataEvento >= @DallaDataReferto OR @DallaDataReferto IS NULL) AND (RP.DataEvento <= @AllaDataReferto OR @AllaDataReferto IS NULL)
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