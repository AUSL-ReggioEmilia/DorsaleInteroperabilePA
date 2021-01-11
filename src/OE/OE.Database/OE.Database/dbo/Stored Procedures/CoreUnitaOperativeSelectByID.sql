-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-11-18, eliminato il campo U.IDParametroSpecifico
-- Modify date: 2014-10-01, Sandro - Integrazione SAC
-- Description:	Seleziona l'unità operativa per codice
-- =============================================
CREATE PROCEDURE [dbo].[CoreUnitaOperativeSelectByID]
	@ID uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		-- Controllo se c'è in locale
		IF NOT EXISTS (SELECT * FROM UnitaOperativeEstesa WHERE ID = @ID)
		BEGIN
			-- Allineo tabella locale
			EXEC [dbo].[CoreUnitaOperativeEstesaAllinea] @ID, NULL, NULL
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
		WHERE U.ID = @ID
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUnitaOperativeSelectByID] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUnitaOperativeSelectByID] TO [DataAccessWs]
    AS [dbo];

