
-- =============================================
-- Author:		Marco Bellini
-- Create date: 2011-02-09
-- Description:	Looukup sugli stati dell'ordine
-- =============================================
CREATE PROCEDURE [dbo].[UiLookupSistemiEroganti]

	@Codice varchar(16) = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SELECT Id, Codice, (CodiceAzienda + '-' + ISNULL( Codice,Descrizione)) as Descrizione 
			FROM Sistemi
			WHERE (@Codice is null or Codice = @Codice)
			  AND Erogante = 1 and Attivo = 1
			order by CodiceAzienda, Descrizione, Codice
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END











GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiLookupSistemiEroganti] TO [DataAccessUi]
    AS [dbo];

