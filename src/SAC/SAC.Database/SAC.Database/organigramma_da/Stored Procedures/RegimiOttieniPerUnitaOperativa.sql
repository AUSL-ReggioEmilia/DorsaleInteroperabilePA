-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-07-14
-- Description: Recupera i Regimi abilitati per l'unità operativa, oppure tutti i regimi se @Codice + @CodiceAzienda = NULL
-- Modify date: 
-- =============================================
CREATE PROCEDURE [organigramma_da].[RegimiOttieniPerUnitaOperativa]
(
 @CodiceAzienda varchar(16),
 @Codice varchar(16) --codice unità operativa
)
AS
BEGIN
  BEGIN TRY
		
	-- SE UNITA' OPERATIVA NON PASSATA O NON HA DEI REGIMI ASSOCIATI RESTITUISCO TUTTI I REGIMI
	IF (@Codice + @CodiceAzienda) IS NULL 
	   OR NOT EXISTS 
	   ( SELECT 1 FROM 
		 organigramma.UnitaOperativeRegimi UR
		 INNER JOIN organigramma.UnitaOperative UO ON UO.ID = UR.IdUnitaOperativa
		 WHERE UO.Codice = @Codice AND UO.CodiceAzienda = @CodiceAzienda )
	BEGIN

		SELECT
			R.Codice,
			R.Descrizione
		FROM 
			organigramma.Regimi R 
		ORDER BY
			R.Ordine

	END
	ELSE BEGIN --ALTRIMENTI SOLO I REGIMI IMPOSTATI
		
		SELECT
			R.Codice,
			R.Descrizione
		FROM 
			organigramma.Regimi R
		INNER JOIN
			organigramma.UnitaOperativeRegimi UR
			ON R.Codice = UR.CodiceRegime
		INNER JOIN organigramma.UnitaOperative UO
			ON UO.ID = UR.IdUnitaOperativa
		WHERE 
			UO.Codice = @Codice
			AND UO.CodiceAzienda=@CodiceAzienda
		ORDER BY
			R.Ordine
	
	END

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

