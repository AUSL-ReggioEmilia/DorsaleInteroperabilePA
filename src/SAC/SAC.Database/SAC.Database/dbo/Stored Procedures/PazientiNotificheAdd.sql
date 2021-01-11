


CREATE PROCEDURE [dbo].[PazientiNotificheAdd] 
	  @IdPaziente AS uniqueidentifier
	, @Tipo AS tinyint
	, @Utente AS varchar(64)
	, @IdPazienteFuso UNIQUEIDENTIFIER = NULL
AS
BEGIN
/*
	MODIFICA ETTORE 2015-06-25: 
		Aggiunto parametro @IdPazienteFuso NULL per modifiche future
		Abbiamo gestito in base al tipo che rappresenta una fusione lo scambio dei valori dei parametri
		Se Tipo = 3,4,5,6 il parametro @IdPaziente rappresenta il figlio quindi li devo scambiare
			@IdPazienteFuso <- @IdPaziente		
			@IdPaziente <- [dbo].[GetPazienteRootByPazienteId](@IdPaziente) 
		Gestendo in questo modo abbiamo evitato di dovere modificare la DataAccess quando viene eseguita la "fusione al volo"
		che inserisce una notifica con Tipo=4

		0=Msg
		1=UI
		2=WS
		3=Batch
		4=Msg-notifica-merge
		5=UI-notifica-merge
		6=WS-merge
		7=Aggiornamento padre a seguito modifica data decesso del fuso 
		
	MODIFICA ETTORE 2016-02-22: 
		In caso di Tipo IN (1,2) (aggiornamento da WS o da UI) verifico se l'anagrafica
		IdPaziente è fusa e in tal caso non inserisco il record di notifica

	MODIFICA ETTORE 2015-05-26: salvataggio PazientiNotificheUtenti.DataInvio in caso di operazione esguita da data access	a scopo di log

	MODIFICA ETTORE 2016-08-01: Aggiunto nuovo tipo = 7 = Notifica padre a seguito di modifica data decesso su di un figlio
								Il codice della SP non è stato modificato

	MODIFICA ETTORE 2018-05-08: Aggiunto nuovo tipo = 8 (= MOdifica consesno) e 9 (=modifica esenzione) 
								Il codice della SP non è stato modificato

*/
	DECLARE @IdNotifica AS uniqueidentifier
	DECLARE @Disattivato AS TINYINT
	SET NOCOUNT ON;

	--
	-- Verifico se l'anagrafica aggiornata è fusa e in tal caso non eseguo l'inserimento delle notifiche
	--	
	IF @Tipo IN (1,2) --aggiornamento da WS o da UI
	BEGIN 
		SELECT @Disattivato = Disattivato FROM Pazienti WHERE Id = @IdPaziente
		IF @Disattivato = 2 
		BEGIN
			RETURN
		END 
	END	
	--
	--
	--	
	IF @Tipo IN (3,4,5,6) AND @IdPazienteFuso IS NULL
	BEGIN
		--Per Tipo = 3,4,5,6 @IdPaziente equivale al paziente fuso (figlio) quindi lo scrivo nel parametro @IdPazienteFuso 
		SET @IdPazienteFuso = @IdPaziente
		--Ora @IdPaziente per Tipo = 3,4,5,6 (e anche per tutti gli altri casi) deve essere il padre, quindi lo traslo nel padre
		SET @IdPaziente = dbo.GetPazienteRootByPazienteId(@IdPaziente)
	END
	

	SET @IdNotifica = NEWID()
	--
	-- Notifica
	--
	INSERT INTO PazientiNotifiche(Id, IdPaziente, Tipo, Utente, IdPazienteFuso)
	VALUES     (@IdNotifica, @IdPaziente, @Tipo, @Utente, @IdPazienteFuso)
	--
	-- Utente anonimo
	--
	--MODIFICA ETTORE 2015-05-26: salvataggio PazientiNotificheUtenti.DataInvio in caso di operazione eseguita da data access a scopo di log
	IF @Tipo = 0
	BEGIN 
		--Poichè la notifica la farà l'orchestrazione abbiamo aggiunto la data per scopi di log
		INSERT INTO PazientiNotificheUtenti (IdPazientiNotifica, InvioData)
		VALUES     (@IdNotifica, GETDATE())
	END 
	ELSE
	BEGIN 
		INSERT INTO PazientiNotificheUtenti (IdPazientiNotifica)
		VALUES     (@IdNotifica)
	END 

	--
	-- Utente con ACK
	--
	INSERT INTO PazientiNotificheUtenti
						  (IdPazientiNotifica, InvioUtente, InvioSoapUrl)
	SELECT     @IdNotifica AS IdPazientiNotifica, Utente, NotificheUrl
	FROM         PazientiUtenti
	WHERE     (NotificheAck = 1)

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiNotificheAdd] TO [DataAccessDll]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiNotificheAdd] TO [DataAccessUi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiNotificheAdd] TO [DataAccessDwhFusioni]
    AS [dbo];

