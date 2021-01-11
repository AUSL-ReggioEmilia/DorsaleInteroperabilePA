

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna un sistema e se non esiste lo inserisce e ritorna lo stesso
-- =============================================
CREATE PROC [organigramma_da].[SistemiOttieniOppureInserisce]
(
 @Codice varchar(16),
 @CodiceAzienda varchar(16),
 @Descrizione varchar(128),
 @Erogante bit,
 @Richiedente bit
)
AS
BEGIN
SET NOCOUNT OFF

  	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[SistemiOttieniOppureInserisce]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[SistemiOttieniOppureInserisce]!', 16, 1)
		RETURN
	END

	IF [organigramma].[LeggePermessiScrittura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[SistemiOttieniOppureInserisce]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[SistemiOttieniOppureInserisce]!', 16, 1)
		RETURN
	END

	SELECT 
		[ID],
		[Codice],
		[CodiceAzienda],
		[Descrizione],
		[Erogante],
		[Richiedente],
		[Attivo]
	FROM  [organigramma].[Sistemi]
	WHERE [Codice] = @Codice
		AND [CodiceAzienda] = @CodiceAzienda

	-- Se non trovato aggiunge
	IF @@ROWCOUNT = 0
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION;

			DECLARE @UtenteInserimento varchar(128) = SUSER_NAME()

			INSERT INTO [organigramma].[Sistemi]
				(
				[Codice],
				[CodiceAzienda],
				[Descrizione],
				[Erogante],
				[Richiedente],
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
				INSERTED.[Erogante],
				INSERTED.[Richiedente],
				INSERTED.[Attivo]
				VALUES
				(
				NULLIF(@Codice, ''),
				NULLIF(@CodiceAzienda, ''),
				NULLIF(@Descrizione, ''),
				@Erogante,
				@Richiedente,
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

			EXEC [organigramma].[EventiErrore] NULL, @ErrorLogId, '[organigramma_da].[SistemiOttieniOppureInserisce]', 'Vedi la tabella ErrorLog!'

			EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
			RETURN @ErrorLogId
		END CATCH;

	END
END


