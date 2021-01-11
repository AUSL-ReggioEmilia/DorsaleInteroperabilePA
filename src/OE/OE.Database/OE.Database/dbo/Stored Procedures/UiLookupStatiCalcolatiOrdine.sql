
-- =============================================
-- Author:		Marco Bellini
-- Create date: 2011-02-09
-- Description:	Looukup sugli stati dell'ordine
-- =============================================
CREATE PROCEDURE [dbo].[UiLookupStatiCalcolatiOrdine]

	@Codice varchar(16) = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

		SELECT  
			 Descrizione
      
  FROM [dbo].OrdiniStatiCalcolati
			
			order by Ordine
	
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiLookupStatiCalcolatiOrdine] TO [DataAccessUi]
    AS [dbo];

