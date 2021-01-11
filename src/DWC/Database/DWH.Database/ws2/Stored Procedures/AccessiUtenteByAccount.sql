CREATE PROCEDURE [ws2].[AccessiUtenteByAccount]
(
	@Account AS VARCHAR(128)
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-06-11: restituisce la lista degli accessi associati dell'utente 
		-Legge dalla tabella Utenti quale è l'IdRuolo associato all'account
		-Trovato IdRUolo legge la sua lista degli accessi da SAC-ORGANIGRAMMA e li restituisce
*/
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
	-- Restituisco la lista degli accessi associati al ruolo
	--
	SELECT Accesso FROM [dbo].[SAC_RuoliAccesso] WHERE IdRuolo = @IdRuolo
	
END
