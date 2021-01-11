
-- =============================================
-- Author:		Marco Bellini
-- Create date: 2011-02-09
-- Description:	Looukup sugli stati dell'ordine
-- =============================================
CREATE PROCEDURE [dbo].[UiLookupUnitaOperative]

	@Codice varchar(16) = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		  SELECT Id, Codice, (CodiceAzienda + '-' + ISNULL(Descrizione, Codice)) as Descrizione
			FROM UnitaOperative
			WHERE (Codice = @Codice or @Codice is null)
			and Attivo = 1
			
			ORDER BY CodiceAzienda, Descrizione, Codice
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiLookupUnitaOperative] TO [DataAccessUi]
    AS [dbo];

