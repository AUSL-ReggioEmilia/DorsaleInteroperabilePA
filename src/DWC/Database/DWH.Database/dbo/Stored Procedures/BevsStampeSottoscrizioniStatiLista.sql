-- =============================================
-- Author:		Ettore
-- Create date: 2013-04-17
-- Description:	Restituisce i possibili stati di una sottoscrizione
-- =============================================
CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniStatiLista]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
		Id
		, Descrizione  
	FROM 
		StampeSottoscrizioniStati
		
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniStatiLista] TO [ExecuteFrontEnd]
    AS [dbo];

