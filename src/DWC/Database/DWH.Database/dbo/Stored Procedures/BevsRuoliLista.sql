
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-06-10
-- Description: Restituisce la lista dei ruoli utente letta dal SAC
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[BevsRuoliLista]
	@IdUtente UNIQUEIDENTIFIER
AS
BEGIN

	SET NOCOUNT ON

	SELECT   
		 Id
		,Codice
		,COALESCE(Codice + ' - ' + Descrizione, Descrizione, Codice) AS Descrizione
		
	FROM 
		dbo.SAC_RuoliUtenti 
	INNER JOIN
		dbo.SAC_Ruoli ON  SAC_RuoliUtenti.IdRuolo = SAC_Ruoli.Id 
					  AND SAC_RuoliUtenti.IdUtente = @IdUtente

    WHERE 
		Attivo = 1
		
	ORDER BY   
		Codice, Descrizione

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRuoliLista] TO [ExecuteFrontEnd]
    AS [dbo];

