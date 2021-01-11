

-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-07-13
-- Description: Insert / Update / Delete nella tabella UnitaOperativeRegimi
-- Modify date: 
-- =============================================
CREATE PROCEDURE [organigramma_admin].[UnitaOperativeRegimiModifica]
(
 @UtenteModifica varchar(128),
 @IdUnitaOperativa uniqueidentifier,
 @CodiceRegime varchar(16),
 @Abilitato BIT 
)
AS
BEGIN
  SET NOCOUNT OFF
  
/*
  ESEGUE:
   - UN INSERIMENTO SE LA RIGA MANCA E @Abilitato=1
   - UNA DELETE SE LA RIGA C'E' E @Abilitato=0
*/

  BEGIN TRY
   		
	IF EXISTS 
	( 
		SELECT ID
		FROM organigramma.UnitaOperativeRegimi
		WHERE 
			IdUnitaOperativa = @IdUnitaOperativa
			AND	CodiceRegime = @CodiceRegime	
	)		
	BEGIN
	
		IF @Abilitato = 0  --CANCELLAZIONE RECORD
		BEGIN
		
			DELETE 
				organigramma.UnitaOperativeRegimi
			WHERE 
				IdUnitaOperativa = @IdUnitaOperativa
				AND	CodiceRegime = @CodiceRegime	
			
		END
		--ELSE BEGIN  non necessario				
		--END
	END
	ELSE --INSERIMENTO
	IF @Abilitato = 1  BEGIN
				
		INSERT INTO organigramma.UnitaOperativeRegimi
		(
		 IdUnitaOperativa,
		 CodiceRegime,		
		 DataInserimento,
		 DataModifica,
		 UtenteInserimento,
		 UtenteModifica
		)
		VALUES 
		(
		 @IdUnitaOperativa,
		 @CodiceRegime,		
		 GETUTCDATE(),
		 GETUTCDATE(),
		 @UtenteModifica,
		 @UtenteModifica
		)
		
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

