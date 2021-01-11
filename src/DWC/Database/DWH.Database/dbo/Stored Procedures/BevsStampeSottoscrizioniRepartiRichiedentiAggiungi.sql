-- =============================================
-- Author:		Ettore
-- Create date: 2013-04-17
-- Description:	Crea un nuovo abbanamento ad un reparto richiedente relativamente ad una sottoscrizione
-- =============================================
CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniRepartiRichiedentiAggiungi]
(
	@IdStampeSottoscrizioni UNIQUEIDENTIFIER
	, @IdRepartiRichiedentiSistemiEroganti UNIQUEIDENTIFIER
) 
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO StampeSottoscrizioniRepartiRichiedenti(IdStampeSottoscrizioni, IdRepartiRichiedentiSistemiEroganti)
    VALUES(@IdStampeSottoscrizioni, @IdRepartiRichiedentiSistemiEroganti)
   
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniRepartiRichiedentiAggiungi] TO [ExecuteFrontEnd]
    AS [dbo];

