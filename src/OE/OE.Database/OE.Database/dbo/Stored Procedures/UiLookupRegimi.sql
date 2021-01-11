
-- =============================================
-- Author:		Marco Bellini
-- Create date: 2011-02-09
-- Description:	Looukup sugli stati dell'ordine
-- =============================================
CREATE PROCEDURE [dbo].[UiLookupRegimi]

	@Codice varchar(16) = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SELECT Codice, ISNULL(Descrizione, Codice) as Descrizione 
			FROM Regimi
			WHERE Codice = @Codice or @Codice is null
			
			order by Codice
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiLookupRegimi] TO [DataAccessUi]
    AS [dbo];

