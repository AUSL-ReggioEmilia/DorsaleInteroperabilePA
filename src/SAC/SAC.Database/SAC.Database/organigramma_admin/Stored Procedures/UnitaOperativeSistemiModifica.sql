CREATE PROC [organigramma_admin].[UnitaOperativeSistemiModifica]
(
 @UtenteModifica varchar(128),
 @IdUnitaOperativa uniqueidentifier,
 @IdSistema uniqueidentifier,
 @Codice varchar(16), --SE CODICE E' VUOTO O NULL, ELIMINO LA TRANSCODIFICA PER QUEL SISTEMA
 @CodiceAzienda varchar(16),
 @Descrizione varchar(128)
)
AS
BEGIN
  SET NOCOUNT OFF
  
/*
**  ESEGUE:
**   - UN INSERIMENTO SE LA RIGA MANCA E @CODICE <> NULL,
**   - UNA UPDATE SE LA RIGA C'E' GIA' E CODICE O DESCRIZIONE SONO CAMBIATI
**   - UNA DELETE SE LA RIGA C'E' E @CODICE = NULL
*/

  BEGIN TRY
    BEGIN TRANSACTION;

	IF @Codice='' SET @Codice=NULL
	IF @Descrizione='' SET @Descrizione=NULL
	
	IF EXISTS 
	( 
		SELECT ID
		FROM organigramma.UnitaOperativeSistemi
		WHERE 
			IdUnitaOperativa = @IdUnitaOperativa
			AND	IdSistema = @IdSistema	
	)		
	BEGIN
	
		IF @Codice IS NULL  --CANCELLAZIONE RECORD
		BEGIN
		
			DELETE 
				organigramma.UnitaOperativeSistemi
			WHERE 
				IdUnitaOperativa = @IdUnitaOperativa
				AND	IdSistema = @IdSistema
		END
		ELSE BEGIN  --UPDATE PER VARIAZIONE DEL CODICE O DELLA DESCRIZIONE
			
			UPDATE organigramma.UnitaOperativeSistemi
			SET
				Codice = @Codice,
				Descrizione = @Descrizione,
				DataModifica = GETUTCDATE(),
				UtenteModifica = @UtenteModifica
				
			WHERE 
				IdUnitaOperativa = @IdUnitaOperativa
				AND	IdSistema = @IdSistema			
				AND (
				      Codice <> @Codice 
				      OR ISNULL(Descrizione,'') <> ISNULL(@Descrizione,'')
				    )
				
		END
	END
	ELSE IF @Codice IS NOT NULL --INSERIMENTO
	BEGIN
				
		INSERT INTO organigramma.UnitaOperativeSistemi
		(
		 IdUnitaOperativa,
		 IdSistema,
		 Codice,
		 CodiceAzienda,
		 Descrizione,
		 DataInserimento,
		 DataModifica,
		 UtenteInserimento,
		 UtenteModifica
		)
		VALUES 
		(
		 @IdUnitaOperativa,
		 @IdSistema,
		 @Codice,
		 @CodiceAzienda,
		 @Descrizione,
		 GETUTCDATE(),
		 GETUTCDATE(),
		 @UtenteModifica,
		 @UtenteModifica
		)
		
	END
		
    COMMIT TRANSACTION;

    RETURN 0

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

