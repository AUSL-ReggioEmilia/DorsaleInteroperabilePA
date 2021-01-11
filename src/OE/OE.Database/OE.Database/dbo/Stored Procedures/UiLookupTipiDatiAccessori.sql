
-- =============================================
-- Author:		Marco Bellini
-- Create date: 2011-02-09
-- Modify date: 2018-06-13 Rinominata tabella
-- Description:	Looukup sugli stati dell'ordine
-- =============================================
CREATE PROCEDURE [dbo].[UiLookupTipiDatiAccessori]

	@Codice varchar(16) = NULL
	
AS
BEGIN
	SET NOCOUNT ON;
		
		SELECT  Descrizione as Tipo
			FROM DatiAccessoriTipi
			wHERE (@Codice is null or Codice = @Codice)
			 
			order by Ordine				
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiLookupTipiDatiAccessori] TO [DataAccessUi]
    AS [dbo];

