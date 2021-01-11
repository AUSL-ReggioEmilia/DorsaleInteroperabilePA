

-- =============================================
-- Author:      ETTORE G.
-- Create date: 2015-05-22
-- Description: Scrittura del Log degli accessi
-- Modify date: 2015-10-28 Stefano P: Aggiunto campo Note, tolto WITH RECOMPILE
-- Modify date: 2018-04-17 SimoneB: Aggiunti parametri NumeroRecord,ConsensoPaziente e IdNotaAnamenstica
-- =============================================
CREATE PROCEDURE [frontend].[TracciaAccessiAggiungi]
(
	  @IdUtente		UNIQUEIDENTIFIER	--L'id di Active Directory dell'utente loggato
	, @DomainName	VARCHAR(32)			--Il dominio dell'utente loggato
	, @AccountName	VARCHAR(64)			--L'account dell'utente loggato
	, @Cognome		VARCHAR(64)			--Il Cognome dell'utente loggato
	, @Nome			VARCHAR(64)			--Il Nome dell'utente loggato
	, @NomeHost		VARCHAR(50)			--Il nome del PC dell'utente loggato
	, @IpHost		VARCHAR(50)			--L'indirizzo IP del PC dell'utente loggato
	, @Operazione	VARCHAR(200)	
	, @IdPazienti	UNIQUEIDENTIFIER
	, @IdReferti	UNIQUEIDENTIFIER
	, @IdRicoveri	UNIQUEIDENTIFIER
	, @IdEventi		UNIQUEIDENTIFIER 
	, @RuoloUtenteCodice		VARCHAR(16)
	, @RuoloUtenteDescrizione	VARCHAR(128)
	, @MotivoAccesso			VARCHAR(128)
	, @Note						VARCHAR(254) = NULL
	, @NumeroRecord INT = NULL
	, @ConsensoPaziente VARCHAR(64) = NULL
	, @IdNotaAnamnestica UNIQUEIDENTIFIER = NULL
)
AS
BEGIN 
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsTracciaAccessiAggiungi4
		Utilizzo le viste store.RefertiBase, store.RicoveriBase, store.EventiBase
	--------------
	La SP passa i campi @IdUtente=Id di Active Directory, @Cognome, @Nome che prima venivano ricavati dalla tabella Utenti
	FUNZIONAMENTO:
			-Uno solo di IdReferti, IdRicoveri, IdEventi deve essere valorizzato.
			-Se l'IdPaziente non è valorizzato lo si ricava tramite query per Id<Oggetto> (sulla tabella RefertiBase, RicoveriBase, EventiBase)
			-Dall'Id<Oggetto> valorizzato si ricava l'IdEsterno
*/
	SET NOCOUNT ON

	DECLARE @IdTracciaAccessi UNIQUEIDENTIFIER
	DECLARE @UtenteDisplayName as varchar(128) -- @Cognome + @Nome
	DECLARE @IdEsterno VARCHAR(64) 
	
	IF @IdPazienti IS NULL 
		SET @IdPazienti = '00000000-0000-0000-0000-000000000000'

	--
	-- Se non trovo l'utente valorizzo con valori di default @IdUtenti e @UtenteDisplayName
	--
	IF @IdUtente IS NULL
	BEGIN
		SET @IdUtente = CONVERT(uniqueidentifier, '00000000-0000-0000-0000-000000000000')
		SET @UtenteDisplayName = ISNULL(@DomainName, '') + '\' + ISNULL(@AccountName,'')
	END
	ELSE
	BEGIN
		SET @UtenteDisplayName = ISNULL(@Cognome, '') + ' ' + ISNULL(@Nome,'')
	END 
	--
	-- Devo fare query per trovare IdEsterno, ricavo anche l'IdPaziente
	-- e lo uso nel caso il parametro @IdPaziente non sia valorizzato
	--
	DECLARE @IdPazienti2 UNIQUEIDENTIFIER
	SET @IdPazienti2 = NULL
	IF (NOT @IdReferti IS NULL)
	BEGIN 
		SELECT @IdPazienti2=IdPaziente, @IdEsterno=IdEsterno FROM store.RefertiBase WHERE Id = @IdReferti
	END
	ELSE
	IF (NOT @IdRicoveri IS NULL)
	BEGIN 
		SELECT @IdPazienti2=IdPaziente, @IdEsterno=IdEsterno FROM store.RicoveriBase WHERE Id = @IdRicoveri 
	END
	IF (NOT @IdEventi IS NULL)
	BEGIN 
		SELECT @IdPazienti2=IdPaziente, @IdEsterno=IdEsterno FROM store.EventiBase WHERE Id = @IdEventi
	END
	IF (NOT @IdNotaAnamnestica IS NULL)
	BEGIN
		SELECT @IdPazienti2 = IdPaziente,@IdEsterno = IdEsterno FROM store.NoteAnamnesticheBase Where Id = @IdNotaAnamnestica
	END
	
	--
	-- Se l'Id del paziente passato come parametro non era valorizzato lo valorizzo
	-- con quello trovato dalle query se diverso da NULL
	--	
	IF (@IdPazienti = '00000000-0000-0000-0000-000000000000')
	BEGIN
		SET @IdPazienti = @IdPazienti2
	END
	SET @IdPazienti = ISNULL(@IdPazienti, '00000000-0000-0000-0000-000000000000')
	--
	-- Creo Id della tabella TracciaAccessi
	--
	SET @IdTracciaAccessi=NEWID()
	--
	-- Inserisco nella tabella TracciaAccessi
	--
	INSERT INTO TracciaAccessi(Id, NomeRichiedente, UtenteRichiedente,  
			IdUtenteRichiedente, IdPazienti, IdReferti,
			Operazione , NomeHostRichiedente, IndirizzoIPHostRichiedente,
			IdRicoveri, IdEventi, IdEsterno, RuoloUtenteCodice, RuoloUtenteDescrizione, MotivoAccesso, Note,NumeroRecord,ConsensoPaziente,IdNotaAnamnestica)
	VALUES (@IdTracciaAccessi, @UtenteDisplayName, ISNULL(@DomainName, '') + '\' + ISNULL(@AccountName,''), 
			@IdUtente, @IdPazienti, @IdReferti, 
			@Operazione, @NomeHost, @IPHost,
			@IdRicoveri, @IdEventi, @IdEsterno, @RuoloUtenteCodice, @RuoloUtenteDescrizione, @MotivoAccesso, @Note,@NumeroRecord,@ConsensoPaziente,@IdNotaAnamnestica)
	--
	-- Restituisco il record inserito
	--
	SELECT 
		Id,
		NomeRichiedente,
		UtenteRichiedente,  
		IdUtenteRichiedente,
		IdPazienti,
		IdReferti,
		Operazione,
		NomeHostRichiedente,
		IndirizzoIPHostRichiedente,
		IdRicoveri,
		IdEventi,
		IdEsterno,
		RuoloUtenteCodice,
		RuoloUtenteDescrizione,
		MotivoAccesso,
		Note,
		NumeroRecord,
		ConsensoPaziente,
		IdNotaAnamnestica
	FROM 
		TracciaAccessi
	WHERE 
		Id=@IdTracciaAccessi
	
END




