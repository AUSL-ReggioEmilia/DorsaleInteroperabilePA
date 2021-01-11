
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-10-24
-- Modify date: 2014-10-01 Sandro - Integrazione SAC
-- Description:	Seleziona il sistema per codice
-- =============================================
CREATE PROCEDURE [dbo].[CoreSistemiSelectByCodice]
	  @Codice varchar(16)
	, @CodiceAzienda varchar(16)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		-- Controllo se c'è in locale
		IF NOT EXISTS (SELECT * FROM SistemiEstesa WHERE Codice = @Codice AND CodiceAzienda = @CodiceAzienda)
		BEGIN
			-- Allineo tabella locale
			EXEC [dbo].[CoreSistemiEstesaAllinea] NULL, @Codice, @CodiceAzienda
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
		WHERE S.Codice = @Codice
			AND S.CodiceAzienda = @CodiceAzienda
		
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiSelectByCodice] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreSistemiSelectByCodice] TO [DataAccessWs]
    AS [dbo];

