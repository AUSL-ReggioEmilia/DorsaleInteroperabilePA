
-- =============================================
-- Author:		Ettore
-- Create date: 2017-1114
-- Description:	Restituisce il ruolo associato all'utente
-- =============================================
CREATE PROCEDURE [ws2].[RuoloUtenteByAccount]
(
	@Account AS VARCHAR(128)
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ErrMsg AS VARCHAR(128)	
	DECLARE @IdRuolo as UNIQUEIDENTIFIER
	--
	-- Ricavo l'Id del ruolo 
	--
	SELECT @IdRuolo = IdRuolo FROM dbo.Utenti WHERE Utente = @Account
	IF @IdRuolo IS NULL
	BEGIN
		SET @ErrMsg = 'L''utente ' + @Account + ' non ha un ruolo associato nella tabella Utenti'
		RAISERROR(@ErrMsg , 16, 1)
		RETURN
	END
	--
	-- Verifico che il ruolo sia fra quelli dell'utente
	--
	IF NOT EXISTS (SELECT * FROM [dbo].[SAC_RuoliUtenti] WHERE Utente = @Account AND IdRuolo = @IdRuolo) 
	BEGIN
		SET @ErrMsg = 'Il ruolo nella tabella Utenti associato a ' + @Account + ' non è un ruolo valido.'
		RAISERROR(@ErrMsg , 16, 1)
		RETURN
	END 
	--
	-- Restituisco l'IdRuolo
	--
	SELECT @IdRuolo AS IdRuolo 
	
END