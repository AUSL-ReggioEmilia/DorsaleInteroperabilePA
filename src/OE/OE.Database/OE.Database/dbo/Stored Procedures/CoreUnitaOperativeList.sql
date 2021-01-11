

-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-11-18, eliminato il campo UO.IDParametroSpecifico
-- Description:	Ritorna un elenco di unità operative
-- =============================================
CREATE PROCEDURE [dbo].[CoreUnitaOperativeList]

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
		SELECT 
			  UO.ID
			, A.Codice AS AziendaCodice
			, A.Descrizione AS AziendaDescrizione				  
			, UO.Codice AS UnitaOperativaCodice
			, UO.Descrizione AS UnitaOperativaDescrizione
		
		FROM 
			UnitaOperative UO
			INNER JOIN Aziende A ON UO.CodiceAzienda = A.Codice
		where Attivo=1
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
























GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUnitaOperativeList] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreUnitaOperativeList] TO [DataAccessWs]
    AS [dbo];

