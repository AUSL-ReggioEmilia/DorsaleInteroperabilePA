

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna una UO e se non esiste la inserisce e ritorna la stessa
-- =============================================
CREATE PROC [organigramma_da].[UnitaOperativeOttieniOppureInserisce]
(
 @Codice varchar(16),
 @CodiceAzienda varchar(16),
 @Descrizione varchar(128)
)
AS
BEGIN
SET NOCOUNT OFF

  	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UnitaOperativeOttieniOppureInserisce]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UnitaOperativeOttieniOppureInserisce]!', 16, 1)
		RETURN
	END

	IF [organigramma].[LeggePermessiScrittura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UnitaOperativeOttieniOppureInserisce]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UnitaOperativeOttieniOppureInserisce]!', 16, 1)
		RETURN
	END

	SELECT 
		[ID],
		[Codice],
		[CodiceAzienda],
		[Descrizione],
		[Attivo]
	FROM  [organigramma].[UnitaOperative]
	WHERE [Codice] = @Codice
		AND [CodiceAzienda] = @CodiceAzienda

	-- Se non trovato aggiunge
	IF @@ROWCOUNT = 0
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION;

			DECLARE @UtenteInserimento varchar(128) = SUSER_NAME()

			INSERT INTO [organigramma].[UnitaOperative]
				(
				[Codice],
				[CodiceAzienda],
				[Descrizione],
				[Attivo],
				[DataInserimento],
				[DataModifica],
				[UtenteInserimento],
				[UtenteModifica]
				)
				OUTPUT 
				INSERTED.[ID],
				INSERTED.[Codice],
				INSERTED.[CodiceAzienda],
				INSERTED.[Descrizione],
				INSERTED.[Attivo]
				VALUES
				(
				NULLIF(@Codice, ''),
				NULLIF(@CodiceAzienda, ''),
				NULLIF(@Descrizione, ''),
				1,
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

			DECLARE @ErrorLogId INT
			EXECUTE dbo.LogError @ErrorLogId OUTPUT;

			EXEC [organigramma].[EventiErrore] NULL, @ErrorLogId, '[organigramma_da].[UnitaOperativeOttieniOppureInserisce]', 'Vedi la tabella ErrorLog!'

			EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
			RETURN @ErrorLogId
		END CATCH;

	END
END


