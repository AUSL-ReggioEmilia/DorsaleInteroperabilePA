

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Rimuove una UO e ritorna la stessa
-- =============================================
CREATE PROC [organigramma_da].[UnitaOperativeRimuove]
(
 @Codice varchar(16),
 @CodiceAzienda varchar(16)
)
AS
BEGIN
	SET NOCOUNT OFF
  
   	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiCancellazione](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UnitaOperativeRimuove]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UnitaOperativeRimuove]!', 16, 1)
		RETURN
	END

	BEGIN TRY
		BEGIN TRANSACTION;

		DELETE FROM [organigramma].[UnitaOperative]
			OUTPUT 
			DELETED.[ID],
			DELETED.[Codice],
			DELETED.[CodiceAzienda],
			DELETED.[Descrizione],
			DELETED.[Attivo]
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

		EXEC [organigramma].[EventiErrore] NULL, @ErrorLogId, '[organigramma_da].[UnitaOperativeRimuove]', 'Vedi la tabella ErrorLog!'

		EXECUTE dbo.RaiseErrorByIdLog @ErrorLogId
		RETURN @ErrorLogId
	END CATCH;
END


