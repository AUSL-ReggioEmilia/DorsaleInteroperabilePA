

-- =============================================
-- Author:		Simone Bitti
-- Create date: 2017-11-10
-- Description: Restituisce l'id del ricovero a partire dal NumeroNosologico e l'AziendaErogante 
--				(utilizzata nelle pagine degli oscuramenti per risalire all'id del ricovero a partire da un evento)
-- =============================================
CREATE PROCEDURE [dbo].[BevsRicoveroOttieniIdByAziendaNosologico]
(
	@AziendaErogante VARCHAR(16),
	@NumeroNosologico VARCHAR(64)
)

AS
BEGIN
	SET NOCOUNT OFF	

	SELECT Id
	FROM store.RicoveriBase
	WHERE (AziendaErogante = @AziendaErogante)
		AND (NumeroNosologico = @NumeroNosologico) 
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRicoveroOttieniIdByAziendaNosologico] TO [ExecuteFrontEnd]
    AS [dbo];

