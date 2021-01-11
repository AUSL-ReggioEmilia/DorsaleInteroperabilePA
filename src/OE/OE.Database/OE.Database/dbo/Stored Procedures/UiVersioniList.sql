-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-03-09
-- Modify date: 2011-03-09
-- Modify date: 2014-10-29 Sandro. Nessun ritorno per evitare controlli
-- Description:	Seleziona le versioni
-- =============================================
CREATE PROCEDURE [dbo].[UiVersioniList]
	@ClrNamespace varchar(32) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------	
		SELECT CONVERT(INT, 1) AS ID
			, CONVERT(VARCHAR(32), 'DBVersion') ClrNamespace
			, CONVERT(VARCHAR(1024), '1.0.0.0') ContractNamespace
			, CONVERT(BIT, 1) AS Valido
		WHERE 1=2
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiVersioniList] TO [DataAccessUi]
    AS [dbo];

