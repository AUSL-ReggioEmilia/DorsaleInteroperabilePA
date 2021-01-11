



-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-26
-- Modify date: 2011-01-26
-- Description:	Ritorna il totale delle righe richieste
-- =============================================
CREATE FUNCTION [dbo].[GetTotaleRigheRichiesteByIDOrdine](
	@IDOrdineTestata uniqueidentifier
)

RETURNS int

AS
BEGIN
	DECLARE @Totale int

	-- Totale Righe Richieste
    SELECT @Totale = COUNT(*) 
		FROM OrdiniRigheRichieste
		WHERE IDOrdineTestata = @IDOrdineTestata

	-- Return	
	RETURN @Totale

END




