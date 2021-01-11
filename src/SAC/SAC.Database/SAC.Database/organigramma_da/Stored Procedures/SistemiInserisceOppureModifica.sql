

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Inserisce se non esiste oppure modifica un sistema e ritorna lo stesso
-- =============================================
CREATE PROC [organigramma_da].[SistemiInserisceOppureModifica]
(
 @Codice varchar(16),
 @CodiceAzienda varchar(16),
 @Descrizione varchar(128),
 @Erogante bit,
 @Richiedente bit,
 @Attivo bit = 1
)
AS
BEGIN
	SET NOCOUNT OFF

   	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiScrittura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[SistemiInserisceOppureModifica]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[SistemiInserisceOppureModifica]!', 16, 1)
		RETURN
	END

	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE @Utente varchar(128) = SUSER_NAME()

		IF NOT EXISTS (SELECT * FROM [organigramma].[Sistemi]  WHERE [Codice] = @Codice
															AND [CodiceAzienda] = @CodiceAzienda)
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
				@Attivo,
				GETUTCDATE(),
				GETUTCDATE(),
				NULLIF(@Utente, ''),
				NULLIF(@Utente, '')
				)
		ELSE
			UPDATE [organigramma].[Sistemi]
				SET
				[Descrizione] = NULLIF(@Descrizione, ''),
				[Erogante] = @Erogante,
				[Richiedente] = @Richiedente,
				[Attivo] = 1,
				[DataModifica] = GETUTCDATE(),
				[UtenteModifica] = NULLIF(@Utente, '')
				OUTPUT 
				INSERTED.[ID],
				INSERTED.[Codice],
				INSERTED.[CodiceAzienda],
				INSERTED.[Descrizione],
				INSERTED.[Erogante],
				INSERTED.[Richiedente],
				INSERTED.[Attivo]
				WHERE [Codice] = @Codice
				AND [CodiceAzienda] = @CodiceAzienda

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

		EXEC [organigramma].[EventiErrore] NULL, @ErrorLogId, '[organigramma_da].[SistemiInserisceOppureModifica]', 'Vedi la tabella ErrorLog!'

		EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
		RETURN @ErrorLogId
	END CATCH;
END


