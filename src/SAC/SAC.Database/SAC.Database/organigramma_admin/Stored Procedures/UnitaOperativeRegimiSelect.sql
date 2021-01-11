
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-07-13
-- Description: Recupera sempre tutti i Regimi e se è presenta una riga in UnitaOperativeRegimi, anche i relativi ID
-- Modify date: 
-- =============================================
CREATE PROCEDURE [organigramma_admin].[UnitaOperativeRegimiSelect]
(
 @IdUnitaOperativa uniqueidentifier
)
AS
BEGIN
  BEGIN TRY 		

	SELECT 
		U.ID,
		U.IdUnitaOperativa,
		R.Codice AS CodiceRegime,
		R.Descrizione,
		CASE 
			WHEN U.ID IS NULL THEN CAST(0 AS BIT)
			ELSE CAST(1 AS BIT)
		END AS Abilitato
	
	FROM 
		organigramma.Regimi R 
	LEFT JOIN
		organigramma.UnitaOperativeRegimi U 
		ON R.Codice = U.CodiceRegime
		AND	U.IdUnitaOperativa = @IdUnitaOperativa
	
	ORDER BY
		R.Ordine
		
  END TRY
  BEGIN CATCH

    IF @@TRANCOUNT > 0
    BEGIN
      ROLLBACK TRANSACTION;
    END

    DECLARE @ErrorLogId INT
    EXECUTE dbo.LogError @ErrorLogId OUTPUT;

    EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
    RETURN @ErrorLogId
  END CATCH;
END

