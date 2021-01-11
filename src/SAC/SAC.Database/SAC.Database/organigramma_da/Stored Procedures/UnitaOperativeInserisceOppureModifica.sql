CREATE PROCEDURE [organigramma_da].[UnitaOperativeInserisceOppureModifica]
@Codice VARCHAR (16), @CodiceAzienda VARCHAR (16), @Descrizione VARCHAR (128), @Attivo BIT=1
AS
BEGIN
	SET NOCOUNT OFF

   	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiScrittura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UnitaOperativeInserisceOppureModifica]', 'Utente non ha i permessi di scrittura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UnitaOperativeInserisceOppureModifica]!', 16, 1)
		RETURN
	END

	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE @Utente varchar(128) = SUSER_NAME()

		IF NOT EXISTS (SELECT * FROM [organigramma].[UnitaOperative]  WHERE [Codice] = @Codice
															AND [CodiceAzienda] = @CodiceAzienda)
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
				@Attivo,
				GETUTCDATE(),
				GETUTCDATE(),
				NULLIF(@Utente, ''),
				NULLIF(@Utente, '')
				)
		ELSE
			UPDATE [organigramma].[UnitaOperative]
				SET
				[Descrizione] = NULLIF(@Descrizione, ''),
				[Attivo] = 1,
				[DataModifica] = GETUTCDATE(),
				[UtenteModifica] = NULLIF(@Utente, '')
				OUTPUT 
				INSERTED.[ID],
				INSERTED.[Codice],
				INSERTED.[CodiceAzienda],
				INSERTED.[Descrizione],
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

		EXEC [organigramma].[EventiErrore] NULL, @ErrorLogId, '[organigramma_da].[UnitaOperativeInserisceOppureModifica]', 'Vedi la tabella ErrorLog!'

		EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
		RETURN @ErrorLogId
	END CATCH;
END



