
CREATE PROC [organigramma_admin].[RuoliAttributiInserisce]
(
 @UtenteInserimento varchar(128),
 @IdRuolo uniqueidentifier, 
 @IdRuoloSistema uniqueidentifier, 
 @IdRuoliUnitaOperative uniqueidentifier, 
 @CodiceAttributo varchar(64),
 @Note varchar(128),
 @TipoAttributo tinyint
)
AS
BEGIN
  SET NOCOUNT OFF

/*

N.B.  QUESTA PROCEDURA INSERISCE UN ATTRIBUTO IN UNA DELLE TABELLE:
	  RuoliAttributi - RuoliSistemiAttributi - RuoliUnitaOperativeAttributi
	  SCEGLIENDO IN BASE AL VALORE DI @TipoAttributo [0,1,2]

*/

  BEGIN TRY
    BEGIN TRANSACTION;

	IF @TipoAttributo = 0 BEGIN 
		
		INSERT INTO [organigramma].[RuoliAttributi]
		  (
		  [IdRuolo],
		  [CodiceAttributo],
		  [Note],
		  [DataInserimento],
		  [DataModifica],
		  [UtenteInserimento],
		  [UtenteModifica]
		  )		
		 VALUES
		  (
		  @IdRuolo,
		  @CodiceAttributo,
		  NULLIF(@Note, ''),
		  GETUTCDATE(),
		  GETUTCDATE(),
		  NULLIF(@UtenteInserimento, ''),
		  NULLIF(@UtenteInserimento, '')
		  )
	END
	 
	IF @TipoAttributo = 1 BEGIN 
		
		INSERT INTO [organigramma].[RuoliSistemiAttributi]
		  (
		  [IdRuoloSistema],
		  [CodiceAttributo],
		  [Note],
		  [DataInserimento],
		  [DataModifica],
		  [UtenteInserimento],
		  [UtenteModifica]
		  )		 
		 VALUES
		  (
		  @IdRuoloSistema,
		  @CodiceAttributo,
		  NULLIF(@Note, ''),
		  GETUTCDATE(),
		  GETUTCDATE(),
		  NULLIF(@UtenteInserimento, ''),
		  NULLIF(@UtenteInserimento, '')
		  )
	END
	
	IF @TipoAttributo = 2 BEGIN 
		
		INSERT INTO [organigramma].[RuoliUnitaOperativeAttributi]
		  (
		  [IdRuoliUnitaOperative],
		  [CodiceAttributo],
		  [Note],
		  [DataInserimento],
		  [DataModifica],
		  [UtenteInserimento],
		  [UtenteModifica]
		  )		
		 VALUES
		  (
		  @IdRuoliUnitaOperative,
		  @CodiceAttributo,
		  NULLIF(@Note, ''),
		  GETUTCDATE(),
		  GETUTCDATE(),
		  NULLIF(@UtenteInserimento, ''),
		  NULLIF(@UtenteInserimento, '')
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
