


-- =============================================
-- Author:		Ettore
-- Create date: 2016-05-18
-- Description:	Restituisce il token più recente associato alla terna [CodiceRuolo, UtenteProcesso, UtenteDelegato]
-- =============================================
CREATE PROCEDURE [ws3].[TokenByRuoloUtenti]
(
	@CodiceRuolo VARCHAR(16)
	, @UtenteProcesso VARCHAR(64)
	, @UtenteDelegato VARCHAR(64)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		--
		-- Restituisco ultimo token associato a [@CodiceRuolo, @UtenteProcesso, @UtenteDelegato]
		--
		SELECT TOP 1 
			Id
			, CodiceRuolo
			, UtenteProcesso
			, UtenteDelegato
		FROM 
			dbo.Tokens
		WHERE 
			CodiceRuolo = @CodiceRuolo 
			AND UtenteProcesso = @UtenteProcesso
			AND UtenteDelegato = @UtenteDelegato
		ORDER BY DataInserimento DESC
    END TRY
    BEGIN CATCH
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()
		DECLARE @report NVARCHAR(4000);
		SELECT @report = @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)		
    END CATCH
END