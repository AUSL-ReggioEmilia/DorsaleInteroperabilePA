-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-12-03
-- Description: Rimozione dell'appartenenza dell'utente al ruolo.
-- =============================================
CREATE PROCEDURE [organigramma_da].[RuoliMembroRimuove]
(
 @CodiceRuolo varchar(16),
 @Utente varchar(128)
)
AS
BEGIN
  SET NOCOUNT OFF

  BEGIN TRY
    BEGIN TRANSACTION;

  	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiScrittura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[RuoliMembroRimuove]', 'Utente non ha i permessi di scrittura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[RuoliMembroRimuove]!', 16, 1)
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
	
	DELETE 
		[organigramma].[RuoliOggettiActiveDirectory]
	WHERE	
		IdRuolo = @IdRuolo
		AND IdUtente = @IdUtente

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