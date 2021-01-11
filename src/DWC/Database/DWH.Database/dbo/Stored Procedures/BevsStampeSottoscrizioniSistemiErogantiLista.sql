-- =============================================
-- Author:		Ettore
-- Create date: 2013-04-17
-- Description:	Restituisce la lista dei sistemi eroganti per le sottoscrizioni alle stampe dei referti
-- =============================================
CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniSistemiErogantiLista]
(
	@AziendaErogante varchar(16)
)
AS
BEGIN 
	SET NOCOUNT ON;
	SELECT 
		SistemaErogante AS Codice
		,Descrizione
	FROM 
		SistemiEroganti 
	WHERE
		SistemiEroganti.AziendaErogante = @AziendaErogante 
		AND ( SistemiEroganti.TipoReferti = 1)
	ORDER BY 
		Descrizione
	SET NOCOUNT OFF;
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniSistemiErogantiLista] TO [ExecuteFrontEnd]
    AS [dbo];

