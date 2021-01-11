




-- =============================================
-- Author:		Bitti Simone
-- Modify date: 2016-11-24
-- Description:	Ottiene la lista delle Prestazioni associate al Dato Accessorio.
-- Modified: il 04/01/2017 da SimoneB - Ottiene il SistemaErogante associando CodiceAzienda e Codice del Sistema.

-- =============================================
CREATE PROCEDURE [dbo].[UiDatiAccessoriPrestazioni]
	@CodiceDatoAccessorio varchar(64)
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY



	SELECT DAP.ID
		  ,PR.ID As IDPrestazione
		  ,PR.Codice
		  ,DAP.CodiceDatoAccessorio
		  ,PR.IDSistemaErogante
		  ,ISNULL(PR.Descrizione,'') as Descrizione
		  ,ISNULL(PR.Attivo, 0) as Attivo
		   ,CASE        
         WHEN Tipo BETWEEN 1 AND 2 THEN  '(Profilo)' 
         ELSE S.CodiceAzienda + '-' + S.Codice + 
				CASE 
					WHEN S.Attivo = 0 THEN ' (Disattivo)'  
					ELSE '' 	
				END		
       END AS SistemaErogante    
	FROM DatiAccessoriPrestazioni DAP 
	LEFT JOIN Prestazioni PR ON DAP.IDPrestazione = PR.ID
	LEFT JOIN Sistemi AS S ON S.ID = PR.IDSistemaErogante
	WHERE 
			DAP.CodiceDatoAccessorio = @CodiceDatoAccessorio

						
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAccessoriPrestazioni] TO [DataAccessUi]
    AS [dbo];

