-- =============================================
-- Author:		Ettore
-- Create date: 2013-04-17
-- Description:	Rimuove un abbonamento ad un reparto richiedente
-- =============================================
CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniRepartiRichiedentiRimuovi]
(
	@IdStampeSottoscrizioni UNIQUEIDENTIFIER,
	@IdRepartiRichiedentiSistemiEroganti UNIQUEIDENTIFIER
) 
AS
BEGIN
	SET NOCOUNT ON;
	
	DELETE FROM StampeSottoscrizioniRepartiRichiedenti
    WHERE IdStampeSottoscrizioni = @IdStampeSottoscrizioni 
      and IdRepartiRichiedentiSistemiEroganti = @IdRepartiRichiedentiSistemiEroganti
   
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniRepartiRichiedentiRimuovi] TO [ExecuteFrontEnd]
    AS [dbo];

