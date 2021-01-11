
CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniRepartiRichiedentiSelezionabili2]
(
	  @AziendaErogante AS VARCHAR(16) = NULL
	, @SistemaErogante AS VARCHAR(16) = NULL
	, @RepartoRichiedenteDescrizione AS VARCHAR(64) = NULL
) WITH RECOMPILE
AS
BEGIN
/*
	CREATA DA ETTORE 2015-07-03: Eliminato i campi RuoloVisualizzazioneRepartoRichiedente e RuoloVisualizzazioneSistemaErogante
*/
	SET NOCOUNT ON;
	
	SELECT 
		  RepartiRichiedentiSistemiEroganti.Id
		, RepartiRichiedentiSistemiEroganti.RepartoRichiedenteDescrizione
		, RepartiRichiedentiSistemiEroganti.RepartoRichiedenteCodice 
		, SistemiEroganti.AziendaErogante
		, SistemiEroganti.SistemaErogante		
	FROM 
		RepartiRichiedentiSistemiEroganti 
			INNER JOIN SistemiEroganti ON SistemiEroganti.Id = RepartiRichiedentiSistemiEroganti.IdSistemaErogante			
	WHERE
		    (
				ISNULL(@RepartoRichiedenteDescrizione,'') = ''
				OR RepartiRichiedentiSistemiEroganti.RepartoRichiedenteDescrizione like '%' + @RepartoRichiedenteDescrizione + '%' 			
			)
		AND (ISNULL(@SistemaErogante,'') = '' OR SistemiEroganti.SistemaErogante = @SistemaErogante)
		AND (SistemiEroganti.TipoReferti = 1) -- Solo sistemi che erogano referti
		AND (ISNULL(@AziendaErogante,'') = '' OR SistemiEroganti.AziendaErogante = @AziendaErogante)
	ORDER BY
		 SistemiEroganti.AziendaErogante
		,SistemiEroganti.SistemaErogante
		,RepartiRichiedentiSistemiEroganti.RepartoRichiedenteDescrizione

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniRepartiRichiedentiSelezionabili2] TO [ExecuteFrontEnd]
    AS [dbo];

