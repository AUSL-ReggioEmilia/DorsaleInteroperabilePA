
-- =============================================
-- Author:		Marco Bellini
-- Create date: 2011-02-09
-- Description:	Looukup sugli stati dell'ordine
-- =============================================
CREATE PROCEDURE [dbo].[UiLookupStatiOrdine]

	@Codice varchar(16) = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SELECT Codice, Descrizione, Ordinamento
			FROM OrdiniStati
			WHERE Codice = @Codice or @Codice is null
			
			order by Ordinamento
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END












GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiLookupStatiOrdine] TO [DataAccessUi]
    AS [dbo];

