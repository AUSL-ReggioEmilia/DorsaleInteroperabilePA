-- =============================================
-- Author:      Stefano P.
-- Create date: 2014
-- Description: Inserimento di un Ruolo
-- Modify date: 2015-07-11 Stefano. Aggiunta gestione della copia ruolo 
-- Modify date: 2018-01-19 SimoneB. Aggiunta parametro @Note
-- =============================================
CREATE PROC [organigramma_admin].[RuoliInserisce]
(
 @UtenteInserimento varchar(128),
 @Codice varchar(16),
 @Descrizione varchar(128),
 @Attivo bit,
 @IdRuoloDaCopiare uniqueidentifier = NULL,
 @Note VARCHAR(1024) = NULL
)
AS
BEGIN
  SET NOCOUNT OFF
  
  DECLARE @INSERTED TABLE (ID UNIQUEIDENTIFIER)
  
  BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO [organigramma].[Ruoli]
      (
      [Codice],
      [Descrizione],
      [Attivo],
      [DataInserimento],
      [DataModifica],
      [UtenteInserimento],
      [UtenteModifica],
	  [Note]

      )
     OUTPUT 
      INSERTED.ID INTO @INSERTED
     VALUES
      (
      NULLIF(@Codice, ''),
      NULLIF(@Descrizione, ''),
      @Attivo,
      GETUTCDATE(),
      GETUTCDATE(),
      NULLIF(@UtenteInserimento, ''),
      NULLIF(@UtenteInserimento, ''),
	  NULLIF(@Note,'')
      )
    
	--
	-- SE RICHIESTO ESEGUO LA COPIA DELLE INFORMAZIONI DAL RUOLO @IdRuoloDaCopiare A QUELLO APPENA INSERITO
	--
	IF @IdRuoloDaCopiare IS NOT NULL BEGIN
		DECLARE @IdRuoloDestinazione UNIQUEIDENTIFIER 
		SELECT @IdRuoloDestinazione=ID FROM @INSERTED	
		EXECUTE [organigramma_admin].[RuoliCopia] @IdRuoloDaCopiare, @IdRuoloDestinazione
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
