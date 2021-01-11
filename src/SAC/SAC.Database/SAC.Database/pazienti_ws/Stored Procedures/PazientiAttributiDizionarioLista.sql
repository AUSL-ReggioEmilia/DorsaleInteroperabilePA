-- =============================================
-- Author:		ETTORE
-- Create date: 2019-11-12
-- Description:	Restituisce la lista dei nomi degli attributi permessi
-- =============================================
CREATE PROCEDURE pazienti_ws.PazientiAttributiDizionarioLista
AS
BEGIN
	SET NOCOUNT ON;
    
	SELECT 
		Nome
	FROM 
		dbo.PazientiAttributiDizionario
END