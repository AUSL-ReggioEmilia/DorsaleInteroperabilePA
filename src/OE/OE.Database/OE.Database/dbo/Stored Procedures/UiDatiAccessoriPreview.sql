

-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-12-05
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[UiDatiAccessoriPreview]
	@CodiceDatoAccessorio varchar(64)
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY


SELECT Descrizione, Tipo From	
(
		SELECT ISNULL(SI.Descrizione, SI.Codice) as Descrizione, 'Sistema' as Tipo
			
from DatiAccessoriSistemi S LEFT JOIN Sistemi SI ON S.IDSistema = SI.ID
	WHERE 
			S.CodiceDatoAccessorio = @CodiceDatoAccessorio
			--AND S.Attivo = 1
			AND SI.Attivo = 1
union all

SELECT ISNULL(PR.Descrizione, PR.Codice) as Descrizione, 'Prestazione' as Tipo 
from DatiAccessoriPrestazioni P LEFT JOIN Prestazioni PR ON P.IDPrestazione = PR.ID
	WHERE 
			P.CodiceDatoAccessorio = @CodiceDatoAccessorio
			--AND P.Attivo = 1	
			AND PR.Attivo = 1	
) as Temp
ORDER BY Tipo,Descrizione
						
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiDatiAccessoriPreview] TO [DataAccessUi]
    AS [dbo];

