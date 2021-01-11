

-- =============================================
-- Author:      Stefano P.
-- Create date: 2014-10
-- Description: Rimuove una riga di dbo.Oscuramenti
-- Modify date: 2015-02-04 Stefano: aggiunti 2 campi
-- Modify date: 2015-04-30 Stefano: aggiunto campo Titolo
-- Modify date: 2015-06-17 Stefano: cancella anche dalla OscuramentoRuoli
-- Modify date: 2016-10-12 Stefano: aggiunti campi ApplicaDWH, ApplicaSole
-- Modify date: 2017-11-07 SimoneB: Inserita Transaction.
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentiRimuove]
(
 @Id uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT ON

  BEGIN TRANSACTION
	 BEGIN TRY
		--RESETTO LO STATO DI ID CORRELAZIONE DELL'OSCURAMENTO ORIGINALE.
		UPDATE dbo.Oscuramenti
		SET IdCorrelazione = NULL
		WHERE IdCorrelazione = @Id

		DELETE FROM OscuramentoRuoli
		 WHERE IdOscuramento = @Id
	 
		DELETE FROM dbo.Oscuramenti
		 OUTPUT 
		  DELETED.Id,
		  DELETED.CodiceOscuramento,
		  DELETED.AziendaErogante,
		  DELETED.SistemaErogante,
		  DELETED.NumeroNosologico,
		  DELETED.RepartoRichiedenteCodice,
		  DELETED.NumeroPrenotazione,
		  DELETED.NumeroReferto,
		  DELETED.IdOrderEntry,
		  DELETED.Note,
		  DELETED.RepartoErogante,
		  DELETED.StrutturaEroganteCodice,
		  DELETED.TipoOscuramento,
		  DELETED.Titolo,
		  DELETED.ApplicaDWH, 
		  DELETED.ApplicaSole
		WHERE Id = @Id

		COMMIT

	END TRY
	BEGIN CATCH
	--
		-- Rollback delle modifiche
		--
		IF @@TRANCOUNT > 0 ROLLBACK
						
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BevsOscuramentiRimuove. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
	
	END CATCH
    
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentiRimuove] TO [ExecuteFrontEnd]
    AS [dbo];

