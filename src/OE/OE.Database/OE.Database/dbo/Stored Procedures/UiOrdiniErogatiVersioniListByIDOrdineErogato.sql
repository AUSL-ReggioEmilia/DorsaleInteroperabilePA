-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-01-27
-- Modify date: 2014-03-10 SANDRO: Compressione XML
-- Description:	Lista di versioni ordini erogati
-- =============================================
CREATE PROCEDURE [dbo].[UiOrdiniErogatiVersioniListByIDOrdineErogato]
	@IDOrdineErogatoTestata uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		  ID
		, DataInserimento
		, IDTicketInserimento
		, IDOrdineErogatoTestata
		, StatoOrderEntry
		,CASE WHEN StatoCompressione = 2 THEN CAST(dbo.decompress(DatiVersioneXmlCompresso) AS XML)
			ELSE DatiVersione END AS DatiVersione
		
	FROM OrdiniErogatiVersioni
	
	WHERE IDOrdineErogatoTestata = @IDOrdineErogatoTestata
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiOrdiniErogatiVersioniListByIDOrdineErogato] TO [DataAccessUi]
    AS [dbo];

