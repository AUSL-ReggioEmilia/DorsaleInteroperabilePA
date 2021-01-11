-- =============================================
-- Author:		Ettore
-- Create date: 2013-04-17
-- Description:	Restituisce il tipo di sottoscrizione
-- =============================================
CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniTipoSottoscrizioniLista]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		Id
		, Descrizione  
	FROM 
		StampeSottoscrizioniTipoSottoscrizioni 
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniTipoSottoscrizioniLista] TO [ExecuteFrontEnd]
    AS [dbo];

