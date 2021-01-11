




-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-26
-- Modify date: 2011-01-26
-- Description:	Ritorna il totale delle righe erogate
-- =============================================
CREATE FUNCTION [dbo].[GetTotaleRigheErogateByIDOrdineErogato](
	@IDOrdineErogatoTestata uniqueidentifier
)

RETURNS int

AS
BEGIN
	DECLARE @Totale int

	-- Totale Righe Richieste
    SELECT @Totale = COUNT(*) 
		FROM OrdiniRigheErogate
		WHERE IDOrdineErogatoTestata = @IDOrdineErogatoTestata

	-- Return	
	RETURN @Totale

END





