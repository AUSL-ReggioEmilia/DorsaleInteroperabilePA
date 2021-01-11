
-- =============================================
-- Author:		Marco Bellini
-- Create date: 2011-02-09
-- Description:	Lookup Sistemi Richiedenti
-- Modify date: 2016-10-10 Stefano P.: aggiunto filtro su ID
-- =============================================
CREATE PROCEDURE [dbo].[UiLookupSistemiRichiedenti]
	@Codice varchar(16) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SELECT 
			Id, 
			Codice, 
			(CodiceAzienda + '-' + ISNULL(Codice,Descrizione)) as Descrizione 
		FROM 
			Sistemi
		WHERE 
			(Codice = @Codice OR @Codice IS NULL)
			AND Richiedente = 1 
			AND Attivo = 1
			AND ID <> '00000000-0000-0000-0000-000000000000'
		
		ORDER BY 
			CodiceAzienda, Descrizione, Codice
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiLookupSistemiRichiedenti] TO [DataAccessUi]
    AS [dbo];

