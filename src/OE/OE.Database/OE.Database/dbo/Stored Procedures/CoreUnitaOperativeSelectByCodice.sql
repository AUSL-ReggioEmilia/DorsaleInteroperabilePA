-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-11-18, eliminato il campo U.IDParametroSpecifico
-- Modify date: 2014-10-01, Sandro - Integrazione SAC
-- Description:	Seleziona l'unità operativa per codice
-- =============================================
CREATE PROCEDURE [dbo].[CoreUnitaOperativeSelectByCodice]
	  @Codice varchar(16)
	, @CodiceAzienda varchar(16)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		-- Controllo se c'è in locale
		IF NOT EXISTS (SELECT * FROM UnitaOperativeEstesa WHERE Codice = @Codice AND CodiceAzienda = @CodiceAzienda)
		BEGIN
			-- Allineo tabella locale
			EXEC [dbo].[CoreUnitaOperativeEstesaAllinea] NULL, @Codice, @CodiceAzienda
		END

		------------------------------
		-- SELECT
		------------------------------		
		SELECT U.ID
			, U.Codice
			, U.Descrizione
			, U.CodiceAzienda
			, A.Descrizione AS DescrizioneAzienda
		FROM UnitaOperative U
			INNER JOIN Aziende A ON U.CodiceAzienda = A.Codice
		WHERE U.Codice = @Codice AND U.CodiceAzienda = @CodiceAzienda

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUnitaOperativeSelectByCodice] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUnitaOperativeSelectByCodice] TO [DataAccessWs]
    AS [dbo];

