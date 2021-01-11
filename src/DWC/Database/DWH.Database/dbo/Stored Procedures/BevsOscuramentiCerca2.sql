



-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-06-04
-- Description: Ricerca multi parametro su dbo.Oscuramenti
-- Modify date: 2017-08-30-Simoneb, Aggiunto parametro Top
-- Modify date: 2017-10-02 SimoneB, Gestito tipo di oscuramento 10
-- Modify date: 2017-10-17 SimoneB, Restituito anche il campo Stato.
-- Modify date: 2017-11-08 SimoneB, Non mostro gli oscuramenti con Stato = Completato e IdValorizzo NOT NULL (perchè significa che ne esiste uno pending).
--									Ordino per Stato Desc in modo da visualizzare per primi gli oscuramenti "pending" (stato="inserito")
-- Modify date: 2018-01-15 SimoneB, Aggiunti parametri @ApplicaDwh e @ApplicaSole.
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiCerca2]
(
	@CodiceOscuramento INT = NULL,
	@Titolo varchar(50) = NULL,
	@AziendaErogante varchar(16) = NULL,
	@SistemaErogante varchar(16) = NULL,
	@NumeroNosologico varchar(64) = NULL,
	@RepartoRichiedenteCodice varchar(16) = NULL,
	@NumeroPrenotazione varchar(32) = NULL,
	@NumeroReferto varchar(16) = NULL,
	@IdOrderEntry varchar(64) = NULL,
	@OscoramentiPuntuali BIT = NULL,
	@OscoramentiMassivi BIT = NULL,
	@Top INT = NULL,
	@Stato VARCHAR(16) = NULL,
	@ApplicaDwh BIT = NULL,
	@ApplicaSole BIT = NULL

)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT OFF

	SELECT TOP (ISNULL(@Top, 1000)) 
		Id
		,CodiceOscuramento
		,Titolo
		,TipoOscuramento     
		--,Note
		,AziendaErogante
		,SistemaErogante
		,NumeroNosologico
		,RepartoRichiedenteCodice
		,NumeroPrenotazione
		,NumeroReferto
		,IdOrderEntry            
		,RepartoErogante
		,StrutturaEroganteCodice   
		,Parola
		,IdEsternoReferto
		,dbo.BevsGetRuoliOscuramento(Id) AS Ruoli
		,Stato
		,ApplicaDwh  
		,ApplicaSole
		        
	FROM  dbo.Oscuramenti
	WHERE 
		(CodiceOscuramento = @CodiceOscuramento OR @CodiceOscuramento IS NULL) AND 
		(Titolo LIKE '%' + @Titolo + '%' OR @Titolo IS NULL) AND 
		(AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL) AND 
		(SistemaErogante = @SistemaErogante OR @SistemaErogante IS NULL) AND 
		(NumeroNosologico = @NumeroNosologico OR @NumeroNosologico IS NULL) AND 
		(RepartoRichiedenteCodice LIKE @RepartoRichiedenteCodice + '%' OR @RepartoRichiedenteCodice IS NULL) AND 
		(NumeroPrenotazione = @NumeroPrenotazione OR @NumeroPrenotazione IS NULL) AND 
		(NumeroReferto = @NumeroReferto OR @NumeroReferto IS NULL) AND       
		(IdOrderEntry = @IdOrderEntry OR @IdOrderEntry IS NULL) AND
		( 
			( @OscoramentiPuntuali = 1 AND TipoOscuramento IN (1,3,4,5,9) )        
		OR ( @OscoramentiMassivi  = 1 AND TipoOscuramento IN (0,2,6,7,8,10) )
		) 
		--NON MOSTRO QUELLI CHE HANNO Stato= Completato E CHE HANNO idCorrelazione VALORIZZATO PERCHE' SIGNIFICA CHE E' IN MODIFICA.
		AND NOT (Stato = 'Completato' AND IdCorrelazione IS NOT NULL )
		AND (@Stato IS NULL OR Stato = @Stato)
		AND(@ApplicaDwh IS NULL OR ApplicaDwh = @ApplicaDwh)        
		AND(@ApplicaSole IS NULL OR ApplicaSole = @ApplicaSole)
    
	--MOSTRO PER PRIMI GLI OSCURAMENTI "PENDING"
	ORDER BY CASE WHEN Stato = 'Inserito' THEN 0 ELSE 1 END 
		,CodiceOscuramento 
  
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiCerca2] TO [ExecuteFrontEnd]
    AS [dbo];

