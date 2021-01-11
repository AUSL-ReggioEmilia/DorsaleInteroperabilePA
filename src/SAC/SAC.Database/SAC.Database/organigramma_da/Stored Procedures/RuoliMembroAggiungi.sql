-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-12-03
-- Description: Assegnazione del ruolo all'utente. 
--			Procedura chiamata dall'applicazione DwhClinico3.AccessiAutorizzazione
-- =============================================
CREATE PROCEDURE [organigramma_da].[RuoliMembroAggiungi]
(
 @CodiceRuolo varchar(16),
 @Utente varchar(128)
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

	DECLARE @UtenteInserimento varchar(128) = SUSER_NAME()
	
  	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiScrittura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[RuoliMembroAggiungi]', 'Utente non ha i permessi di scrittura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[RuoliMembroAggiungi]!', 16, 1)
		RETURN
	END
		
	DECLARE	@IdRuolo UNIQUEIDENTIFIER = NULL
	DECLARE	@IdUtente UNIQUEIDENTIFIER = NULL
	
	SELECT @IdRuolo=ID FROM [organigramma].Ruoli
		WHERE Codice=@CodiceRuolo
		
	SELECT @IdUtente=ID FROM [organigramma].OggettiActiveDirectory
		WHERE Utente=@Utente
	
	IF @IdRuolo IS NULL
	BEGIN
		RAISERROR('Errore: Il ruolo non esiste. Procedura: [organigramma_da].[RuoliMembroAggiungi]!', 16, 1)
		RETURN
	END
	
	IF @IdUtente IS NULL
	BEGIN
		RAISERROR('Errore: L''utente non esiste. Procedura: [organigramma_da].[RuoliMembroAggiungi]!', 16, 1)
		RETURN
	END
	
	INSERT INTO [organigramma].[RuoliOggettiActiveDirectory]
	   (
	    [IdRuolo]
	   ,[IdUtente]
	   ,[DataInserimento]
	   ,[DataModifica]
	   ,[UtenteInserimento]
	   ,[UtenteModifica]
	   )
    OUTPUT 
        INSERTED.[IdRuolo]
       ,INSERTED.[IdUtente]
       ,INSERTED.[DataInserimento]
       ,INSERTED.[DataModifica]
       ,INSERTED.[UtenteInserimento]
       ,INSERTED.[UtenteModifica]
    VALUES
		(
		@IdRuolo,
		@IdUtente,
		GETUTCDATE(),
		GETUTCDATE(),
		NULLIF(@UtenteInserimento, ''),
		NULLIF(@UtenteInserimento, '')
		)

    COMMIT TRANSACTION;

    RETURN 0

  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
      ROLLBACK TRANSACTION;
    END
    
	--NASCONDO L'ERRORE IN INSERIMENTO DI CHIAVE DUPLICATA PERCHE' NON OCCORRE MOSTRARLO AL CHIAMANTE
	IF ERROR_NUMBER() = 2601 RETURN 0
	

    DECLARE @ErrorLogId INT
    EXECUTE dbo.LogError @ErrorLogId OUTPUT;

    EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
    RETURN @ErrorLogId
  END CATCH;
END