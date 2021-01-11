-- =============================================
-- Author:		Ettore
-- Create date: 06/02/2008
-- Description:	Restituisce i reparti a cui un utente si è abbonato
-- =============================================
CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniRepartiRichiedentiLista]
(
	@IdStampeSottoscrizioni UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		 StampeSottoscrizioniRepartiRichiedenti.Id 
		,RepartiRichiedentiSistemiEroganti.Id as IdReparto
		,RepartiRichiedentiSistemiEroganti.RepartoRichiedenteCodice
		,RepartiRichiedentiSistemiEroganti.RepartoRichiedenteDescrizione
		
		,SistemiEroganti.SistemaErogante
		,SistemiEroganti.AziendaErogante		
	FROM 
		StampeSottoscrizioniRepartiRichiedenti 
		inner join RepartiRichiedentiSistemiEroganti ON RepartiRichiedentiSistemiEroganti.Id = StampeSottoscrizioniRepartiRichiedenti.IdRepartiRichiedentiSistemiEroganti
		inner join SistemiEroganti ON SistemiEroganti.Id = RepartiRichiedentiSistemiEroganti.IdSistemaErogante
	WHERE
		StampeSottoscrizioniRepartiRichiedenti.IdStampeSottoscrizioni = @IdStampeSottoscrizioni 
	ORDER BY
		RepartiRichiedentiSistemiEroganti.RepartoRichiedenteDescrizione, SistemiEroganti.SistemaErogante, SistemiEroganti.AziendaErogante
		
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniRepartiRichiedentiLista] TO [ExecuteFrontEnd]
    AS [dbo];

