

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-03-02
-- Description:	Restituisce al lista delle coppie di codice AziendaErogante-SistemaErogante presenti nella tabella dbo.SistemiEroganti
-- 
--	Se si aggiunge un nuovo sistema prima di inviare referti/eventi per il nuovo sistema bisogna configurare CORRETTAMENTE la tabella 
--	SistemiEroganti e per sicurezza fare un restart dell'host instance del DwhClinico INPUT, per assicurarsi che questa query venga 
--	eseguita cosi da leggere le ultime modifiche
-- =============================================
CREATE PROCEDURE [dbo].[ExtSistemiErogantiLista]
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- Mi assicuro di eliminare eventuali spazi vuoti
	--
	SELECT 
		LTRIM(RTRIM(AziendaErogante)) AS AziendaErogante
		, LTRIM(RTRIM(SistemaErogante)) AS SistemaErogante
		, TipoReferti 
		, TipoRicoveri 
	FROM dbo.SistemiEroganti WITH(NOLOCK)
	WHERE (
		TipoReferti = 1 
		OR 
		TipoRicoveri = 1
		)

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtSistemiErogantiLista] TO [ExecuteExt]
    AS [dbo];

