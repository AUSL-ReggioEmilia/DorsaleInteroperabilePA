

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Inserisce una UO e ritorna la stessa
-- =============================================
CREATE PROC [organigramma_da].[UnitaOperativeInserisce]
(
 @Codice varchar(16),
 @CodiceAzienda varchar(16),
 @Descrizione varchar(128),
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
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UnitaOperativeInserisce]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UnitaOperativeInserisce]!', 16, 1)
		RETURN
	END

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
			@Attivo,
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

		EXEC [organigramma].[EventiErrore] NULL, @ErrorLogId, '[organigramma_da].[UnitaOperativeInserisce]', 'Vedi la tabella ErrorLog!'

		EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
		RETURN @ErrorLogId
	END CATCH;
END


