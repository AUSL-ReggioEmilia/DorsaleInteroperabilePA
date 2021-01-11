-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-10-24
-- Modify date: 2014-10-01 Sandro - Integrazione SAC
-- Description:	Seleziona il sistema per id
-- =============================================
CREATE PROCEDURE [dbo].[CoreSistemiSelectByID]
	@ID uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		-- Controllo se c'è in locale
		IF NOT EXISTS (SELECT * FROM SistemiEstesa WHERE ID = @ID)
		BEGIN
			-- Allineo tabella locale
			EXEC [dbo].[CoreSistemiEstesaAllinea] @ID, NULL, NULL
		END

		------------------------------
		-- SELECT
		------------------------------		
		SELECT S.ID
			, S.Codice
			, S.Descrizione
			, S.Erogante
			, S.Richiedente
			, S.CodiceAzienda
			, A.Descrizione AS DescrizioneAzienda
		FROM Sistemi S
			INNER JOIN Aziende A ON S.CodiceAzienda = A.Codice
		WHERE S.ID = @ID
			

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiSelectByID] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiSelectByID] TO [DataAccessWs]
    AS [dbo];

