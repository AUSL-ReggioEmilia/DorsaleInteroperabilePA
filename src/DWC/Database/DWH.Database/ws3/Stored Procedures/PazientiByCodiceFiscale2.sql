
-- =============================================
-- Author:		ETTORE 
-- Create date: 2016-10-17
-- Description:	Questa è stata pensata per l'accesso diretto
--				Restituisce lo stesso set di dati delle ws3.PazientiByGeneralita
--				Non restituisco il campo Anteprima ma le sue parti come campi strutturati:
--				NumeroReferti, UltimoRefertoData, UltimoRefertoSistemaErogante (li valorizzo andandoli a leggere facendo un parsing del campo PazientiAnteprima.AnteprimaReferti)
--				I dati dell'ultimo ricovero li ricavo attraverso il campo PazientiRiepilogo.IdUltimoRicovero
--				Restituzione nuovi campi StatoCodice e StatoDescrizione al posto del campo Stato (equivalente a StatoDescrizione)
-- Modify date: 2017-11-21 ETTORE: Aggiunto i campi di anteprima delle note anamnestiche
-- =============================================
CREATE PROCEDURE  [ws3].[PazientiByCodiceFiscale2]
(
	@MaxNumRow		INTEGER
	, @Ordinamento	VARCHAR(128)
	, @CodiceFiscale	VARCHAR(16) --OBBLIGATORIO
	, @Cognome		VARCHAR(64)=NULL
	, @Nome			VARCHAR(64)=NULL
)
AS
BEGIN
	SET NOCOUNT ON
	--
	-- Imposto '' per l'ordinamento di default
	--
	SET @Ordinamento = ISNULL(@Ordinamento ,'')
	--
	-- Limitazione da database
	--
	DECLARE @Top INTEGER
	SELECT @Top = ISNULL([dbo].[GetConfigurazioneInt] ('Ws_Top','Pazienti') , 200)	
	IF @MaxNumRow > @Top SET @MaxNumRow = @Top
	--
	-- Imposto una data minima di accettazione per la ricerca delle info ricoveri e ricavo la relativa data minima di partizione
	--
	DECLARE @DataMinimaAccettazione DATETIME
	SET @DataMinimaAccettazione = DATEADD(day, - 2555, GETDATE()) --7 anni
	DECLARE @DataMinimaPartizione DATETIME
	SET @DataMinimaPartizione = dbo.OttieniFiltroRicoveriPerDataPartizione(@DataMinimaAccettazione)
	--
	--
	--
	SELECT TOP (@MaxNumRow) 
		P.Id
		, P.Cognome		
		, P.Nome
		, P.CodiceFiscale
		, P.DataNascita
		, P.Sesso		
		, P.LuogoNascitaCodice
		, P.LuogoNascita AS LuogoNascitaDescrizione
		, P.CodiceSanitario
		, P.ComuneDomicilioCodice
		, P.ComuneDomicilioDescrizione
		, P.DomicilioCap AS ComuneDomicilioCap
		, P.DomicilioIndirizzo AS IndirizzoDomicilio
		, P.DataDecesso
		--Dati del consenso aziendale: --NULL, 1=Generico, 2=Dossier, 3=DossierStorico
		, P.ConsensoAziendaleCodice
		, P.ConsensoAziendaleDescrizione 		
		, P.ConsensoAziendaleData 
		--
		-- Prendo i dati di PazientiRiepilogo.AnteprimaReferti e li scrivo in campi strutturati
		--
		,AR.NumeroReferti
		,AR.UltimoRefertoSistemaErogante
		,AR.UltimoRefertoData
		--		
		-- Informazioni sull'ultimo ricovero
		--
		, R.Categoria AS EpisodioCategoria
		, R.NumeroNosologicoOrigine AS EpisodioNumeroNosologicoOrigine
		, R.TipoRicoveroCodice AS EpisodioTipoCodice
		, R.TipoRicoveroDescr AS EpisodioTipoDescrizione
		--Stato del ricovero corrente (Dimesso, Ricoverato, Trasferito, In Prenotazione)		
		, R.StatoCodice  AS EpisodioStatoCodice
		, R.StatoDescrizione  AS EpisodioStatoDescrizione
		, R.AziendaErogante AS EpisodioAziendaErogante
		, R.NumeroNosologico AS EpisodioNumeroNosologico
		, R.DataAccettazione AS EpisodioDataApertura
		, R.DataTrasferimento AS EpisodioDataUltimoEvento
		, R.DataDimissione AS EpisodioDataConclusione
		, R.RepartoAccettazioneCodice AS EpisodioStrutturaAperturaCodice
		, R.RepartoAccettazioneDescr AS EpisodioStrutturaAperturaDescrizione
		, R.RepartoCorrenteCodice AS EpisodioStrutturaUltimoEventoCodice
		, R.RepartoCorrenteDescr AS EpisodioStrutturaUltimoEventoDescrizione
		, R.RepartoDimissioneCodice AS EpisodioStrutturaConclusioneCodice
		, R.RepartoDimissioneDescr AS EpisodioStrutturaConclusioneDescrizione
		, R.SettoreCodice AS EpisodioSettoreCodice
		, R.SettoreDescr AS EpisodioSettoreDescrizione
		, R.LettoCodice AS EpisodioLettoCodice
		--
		-- Restituisco i dati di anteprima per le note anamnestiche
		--
		, PA.NumeroNoteAnamnestiche
		, PA.UltimaNotaAnamnesticaData
		, PA.UltimaNotaAnamnesticaSistemaEroganteDescr
	FROM	
		Pazienti AS P
		LEFT OUTER JOIN PazientiAnteprima AS PA
			ON PA.IdPaziente = P.Id
		LEFT OUTER JOIN ws3.Ricoveri AS R
			ON R.Id = PA.IdUltimoRicovero
		OUTER APPLY dbo.ParseAnteprimaReferti(Pa.AnteprimaReferti) AS AR		
		
	WHERE	
		(P.CodiceFiscale = @CodiceFiscale)
		AND (P.Cognome LIKE @Cognome + '%' OR NULLIF(@Cognome, '') IS NULL)
		AND (P.Nome LIKE @Nome + '%'  OR NULLIF(@Nome, '') IS NULL)
	ORDER BY  
	--Default
	CASE @Ordinamento  WHEN '' THEN P.Cognome END ASC 
	, CASE @Ordinamento  WHEN '' THEN P.Nome END ASC
	--Ascendente
	, CASE @Ordinamento  WHEN 'Id@ASC' THEN P.Id END ASC
    , CASE @Ordinamento  WHEN 'Cognome@ASC' THEN P.Cognome END ASC
    , CASE @Ordinamento  WHEN 'Nome@ASC' THEN P.Nome END ASC
    , CASE @Ordinamento  WHEN 'CodiceFiscale@ASC' THEN P.CodiceFiscale END ASC
    , CASE @Ordinamento  WHEN 'DataNascita@ASC' THEN P.DataNascita END ASC
    , CASE @Ordinamento  WHEN 'Sesso@ASC' THEN P.Sesso END ASC    
    , CASE @Ordinamento  WHEN 'LuogoNascitaCodice@ASC' THEN P.LuogoNascitaCodice END ASC
	, CASE @Ordinamento  WHEN 'LuogoNascitaDescrizione@ASC' THEN P.LuogoNascita END ASC    
    , CASE @Ordinamento  WHEN 'CodiceSanitario@ASC' THEN P.CodiceSanitario END ASC
    , CASE @Ordinamento  WHEN 'ComuneDomicilioCodice@ASC' THEN P.ComuneDomicilioCodice END ASC
    , CASE @Ordinamento  WHEN 'ComuneDomicilioDescrizione@ASC' THEN P.ComuneDomicilioDescrizione END ASC    
    , CASE @Ordinamento  WHEN 'ComuneDomicilioCAP@ASC' THEN P.DomicilioCAP END ASC
    , CASE @Ordinamento  WHEN 'IndirizzoDomicilio@ASC' THEN P.DomicilioIndirizzo END ASC    
    , CASE @Ordinamento  WHEN 'DataDecesso@ASC' THEN P.DataDecesso END ASC    
    , CASE @Ordinamento  WHEN 'ConsensoAziendaleCodice@ASC' THEN P.ConsensoAziendaleCodice END ASC		
    , CASE @Ordinamento  WHEN 'ConsensoAziendaleDescrizione@ASC' THEN P.ConsensoAziendaleDescrizione END ASC		    
	, CASE @Ordinamento  WHEN 'ConsensoAziendaleData@ASC' THEN P.ConsensoAziendaleData END ASC		        
	, CASE @Ordinamento  WHEN 'NumeroReferti@ASC' THEN AR.NumeroReferti END ASC
	, CASE @Ordinamento  WHEN 'UltimoRefertoSistemaErogante@ASC' THEN AR.UltimoRefertoSistemaErogante END ASC
    , CASE @Ordinamento  WHEN 'UltimoRefertoData@ASC' THEN AR.UltimoRefertoData END ASC
    , CASE @Ordinamento  WHEN 'EpisodioCategoria@ASC' THEN R.Categoria END ASC		        
    , CASE @Ordinamento  WHEN 'EpisodioNumeroNosologicoOrigine@ASC' THEN R.NumeroNosologicoOrigine END ASC		        
    , CASE @Ordinamento  WHEN 'EpisodioTipoCodice@ASC' THEN R.TipoRicoveroCodice END ASC		        
    , CASE @Ordinamento  WHEN 'EpisodioTipoDescrizione@ASC' THEN R.TipoRicoveroDescr END ASC		        
    , CASE @Ordinamento  WHEN 'EpisodioStatoCodice@ASC' THEN R.StatoCodice END ASC
	, CASE @Ordinamento  WHEN 'EpisodioStatoDescrizione@ASC' THEN R.StatoDescrizione END ASC
    , CASE @Ordinamento  WHEN 'EpisodioAziendaErogante@ASC' THEN R.AziendaErogante END ASC
    , CASE @Ordinamento  WHEN 'EpisodioNumeroNosologico@ASC' THEN R.NumeroNosologico END ASC    
    , CASE @Ordinamento  WHEN 'EpisodioDataApertura@ASC' THEN R.DataAccettazione END ASC			
    , CASE @Ordinamento  WHEN 'EpisodioDataUltimoEvento@ASC' THEN R.DataTrasferimento END ASC			
    , CASE @Ordinamento  WHEN 'EpisodioDataConclusione@ASC' THEN R.DataDimissione END ASC			    
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaAperturaCodice@ASC' THEN R.RepartoAccettazioneCodice END ASC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaAperturaDescrizione@ASC' THEN R.RepartoAccettazioneDescr END ASC		    
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaUltimoEventoCodice@ASC' THEN R.RepartoCorrenteCodice END ASC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaUltimoEventoDescrizione@ASC' THEN R.RepartoCorrenteDescr END ASC   
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaConclusioneCodice@ASC' THEN R.RepartoDimissioneCodice END ASC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaConclusioneDescrizione@ASC' THEN R.RepartoDimissioneDescr END ASC   
    , CASE @Ordinamento  WHEN 'EpisodioSettoreCodice@ASC' THEN R.SettoreCodice END ASC   
    , CASE @Ordinamento  WHEN 'EpisodioSettoreDescrizione@ASC' THEN R.SettoreDescr END ASC   
    , CASE @Ordinamento  WHEN 'EpisodioLettoCodice@ASC' THEN R.LettoCodice END ASC   
    , CASE @Ordinamento  WHEN 'NumeroNoteAnamnestiche@ASC' THEN PA.NumeroNoteAnamnestiche END ASC   
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaData@ASC' THEN PA.UltimaNotaAnamnesticaData END ASC   
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaSistemaEroganteDescr@ASC' THEN PA.UltimaNotaAnamnesticaSistemaEroganteDescr END ASC   
	--Discendente
	, CASE @Ordinamento  WHEN 'Id@DESC' THEN P.Id END DESC
    , CASE @Ordinamento  WHEN 'Cognome@DESC' THEN P.Cognome END DESC
    , CASE @Ordinamento  WHEN 'Nome@DESC' THEN P.Nome END DESC
    , CASE @Ordinamento  WHEN 'CodiceFiscale@DESC' THEN P.CodiceFiscale END DESC
    , CASE @Ordinamento  WHEN 'DataNascita@DESC' THEN P.DataNascita END DESC
    , CASE @Ordinamento  WHEN 'Sesso@DESC' THEN P.Sesso END DESC    
    , CASE @Ordinamento  WHEN 'LuogoNascitaCodice@DESC' THEN P.LuogoNascitaCodice END DESC
	, CASE @Ordinamento  WHEN 'LuogoNascitaDescrizione@DESC' THEN P.LuogoNascita END DESC    
    , CASE @Ordinamento  WHEN 'CodiceSanitario@DESC' THEN P.CodiceSanitario END DESC
    , CASE @Ordinamento  WHEN 'ComuneDomicilioCodice@DESC' THEN P.ComuneDomicilioCodice END DESC
    , CASE @Ordinamento  WHEN 'ComuneDomicilioDescrizione@DESC' THEN P.ComuneDomicilioDescrizione END DESC    
    , CASE @Ordinamento  WHEN 'ComuneDomicilioCAP@DESC' THEN P.DomicilioCAP END DESC
    , CASE @Ordinamento  WHEN 'IndirizzoDomicilio@DESC' THEN P.DomicilioIndirizzo END DESC    
    , CASE @Ordinamento  WHEN 'DataDecesso@DESC' THEN P.DataDecesso END DESC    
    , CASE @Ordinamento  WHEN 'ConsensoAziendaleCodice@DESC' THEN P.ConsensoAziendaleCodice END DESC		
    , CASE @Ordinamento  WHEN 'ConsensoAziendaleDescrizione@DESC' THEN P.ConsensoAziendaleDescrizione END DESC		    
	, CASE @Ordinamento  WHEN 'ConsensoAziendaleData@DESC' THEN P.ConsensoAziendaleData END DESC		        
	, CASE @Ordinamento  WHEN 'NumeroReferti@DESC' THEN AR.NumeroReferti END DESC
	, CASE @Ordinamento  WHEN 'UltimoRefertoSistemaErogante@DESC' THEN AR.UltimoRefertoSistemaErogante END DESC
    , CASE @Ordinamento  WHEN 'UltimoRefertoData@DESC' THEN AR.UltimoRefertoData END DESC
    , CASE @Ordinamento  WHEN 'EpisodioCategoria@DESC' THEN R.Categoria END DESC
    , CASE @Ordinamento  WHEN 'EpisodioNumeroNosologicoOrigine@DESC' THEN R.NumeroNosologicoOrigine END DESC		        
    , CASE @Ordinamento  WHEN 'EpisodioTipoCodice@DESC' THEN R.TipoRicoveroCodice END DESC		        
    , CASE @Ordinamento  WHEN 'EpisodioTipoDescrizione@DESC' THEN R.TipoRicoveroDescr END DESC		        
    , CASE @Ordinamento  WHEN 'EpisodioStatoCodice@DESC' THEN R.StatoCodice END DESC
	, CASE @Ordinamento  WHEN 'EpisodioStatoDescrizione@DESC' THEN R.StatoDescrizione END DESC
    , CASE @Ordinamento  WHEN 'EpisodioAziendaErogante@DESC' THEN R.AziendaErogante END DESC
    , CASE @Ordinamento  WHEN 'EpisodioNumeroNosologico@DESC' THEN R.NumeroNosologico END DESC    
    , CASE @Ordinamento  WHEN 'EpisodioDataApertura@DESC' THEN R.DataAccettazione END DESC			
    , CASE @Ordinamento  WHEN 'EpisodioDataUltimoEvento@DESC' THEN R.DataTrasferimento END DESC			
    , CASE @Ordinamento  WHEN 'EpisodioDataConclusione@DESC' THEN R.DataDimissione END DESC			    
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaAperturaCodice@DESC' THEN R.RepartoAccettazioneCodice END DESC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaAperturaDescrizione@DESC' THEN R.RepartoAccettazioneDescr END DESC		    
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaUltimoEventoCodice@DESC' THEN R.RepartoCorrenteCodice END DESC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaUltimoEventoDescrizione@DESC' THEN R.RepartoCorrenteDescr END DESC   
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaConclusioneCodice@DESC' THEN R.RepartoDimissioneCodice END DESC		
    , CASE @Ordinamento  WHEN 'EpisodioStrutturaConclusioneDescrizione@DESC' THEN R.RepartoDimissioneDescr END DESC   
    , CASE @Ordinamento  WHEN 'EpisodioSettoreCodice@DESC' THEN R.SettoreCodice END DESC   
    , CASE @Ordinamento  WHEN 'EpisodioSettoreDescrizione@DESC' THEN R.SettoreDescr END DESC   
    , CASE @Ordinamento  WHEN 'EpisodioLettoCodice@DESC' THEN R.LettoCodice END DESC   
    , CASE @Ordinamento  WHEN 'NumeroNoteAnamnestiche@DESC' THEN PA.NumeroNoteAnamnestiche END DESC
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaData@DESC' THEN PA.UltimaNotaAnamnesticaData END DESC
    , CASE @Ordinamento  WHEN 'UltimaNotaAnamnesticaSistemaEroganteDescr@DESC' THEN PA.UltimaNotaAnamnesticaSistemaEroganteDescr END DESC

END