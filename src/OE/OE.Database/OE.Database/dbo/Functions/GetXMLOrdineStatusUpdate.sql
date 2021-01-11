



-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-03-07
-- Modify date: 2011-03-07
-- Description:	Ritorna un xml relativo ad un ordine
-- =============================================
CREATE FUNCTION [dbo].[GetXMLOrdineStatusUpdate](
	@IDOrderEntry uniqueidentifier
)

RETURNS xml

AS
BEGIN
	DECLARE @OrdineTestata xml	
	
	-- Testata
    SET @OrdineTestata = 
	(
		SELECT 
			  Testata.ID
			, Testata.DataModifica
			, Testata.IDTicketModifica
			, Testata.Anno
			, Testata.Numero
			, Testata.IDUnitaOperativaRichiedente
			, Testata.IDSistemaRichiedente
			, Testata.IDRichiestaRichiedente
			, Testata.DataRichiesta
			, Testata.StatoOrderEntry
			
		FROM 
			OrdiniTestate AS Testata
			
		WHERE 
			ID = @IDOrderEntry
			
		FOR XML AUTO, ELEMENTS
	)
	
	-- Return	
	RETURN @OrdineTestata

END




