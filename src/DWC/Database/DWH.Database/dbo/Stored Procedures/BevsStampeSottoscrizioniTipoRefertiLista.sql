-- =============================================
-- Author:		Ettore
-- Create date: 2013-04-17
-- Description:	Restituisce il tipo di referti da stampare
-- =============================================
CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniTipoRefertiLista]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
		Id
		, Descrizione  
	FROM 
		StampeSottoscrizioniTipoReferti
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniTipoRefertiLista] TO [ExecuteFrontEnd]
    AS [dbo];

