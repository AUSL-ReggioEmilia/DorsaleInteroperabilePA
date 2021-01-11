

-- =============================================
-- Author:		Pichierri
-- Create date: ???
-- Description:	Aggiunge un consenso 
-- Modify date: 2018-05-08 ETTORE: A seguito della modifica dei consensi del paziente eseguo anche una notifica paziente di tipo 8
-- =============================================
CREATE PROCEDURE [dbo].[ConsensiMsgBaseUpdate]
	  @Utente varchar(64)
	, @Id uniqueidentifier
	, @IdProvenienza varchar(64)
	, @IdPaziente uniqueidentifier
	, @Tipo varchar(64)
	, @DataStato datetime
	, @Stato bit
	, @OperatoreId varchar(64)
	, @OperatoreCognome varchar(64)
	, @OperatoreNome varchar(64)
	, @OperatoreComputer varchar(64)
	, @PazienteProvenienza varchar(16)
	, @PazienteIdProvenienza varchar(64)
	, @PazienteCognome varchar(64)
	, @PazienteNome varchar(64)
	, @PazienteCodiceFiscale varchar(16)
	, @PazienteDataNascita datetime
	, @PazienteComuneNascitaCodice varchar(6)
	, @PazienteNazionalitaCodice varchar(3)
	, @PazienteTessera varchar(16)
	, @MetodoAssociazione varchar(32)

AS
BEGIN

---------------------------------------------------
-- Variabili
---------------------------------------------------
DECLARE @Provenienza varchar(16)
DECLARE @IdTipo tinyint
DECLARE @Disattivato bit
DECLARE @RowCount integer

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggeConsensiPermessiScrittura(@Utente) = 0
	BEGIN
		EXEC ConsensiEventiAccessoNegato @Utente, 0, 'ConsensiMsgBaseUpdate', 'Utente non ha i permessi di scrittura!'

		RAISERROR('Errore di controllo accessi durante ConsensiMsgBaseUpdate!', 16, 1)
		SELECT 1002 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------

	SET @Provenienza = dbo.LeggeConsensiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante ConsensiMsgBaseUpdate!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	--  Valuto il parametro @Tipo
	---------------------------------------------------	
	SELECT @IdTipo = Id FROM ConsensiTipo WHERE Nome = @Tipo
	
	---------------------------------------------------
	-- Aggiorna i dati senza il controllo della concorrenza (TS)
	---------------------------------------------------	
	UPDATE Consensi
	SET	IdPaziente = @IdPaziente
			, IdTipo = @IdTipo
			, DataStato = @DataStato
			, Stato	= @Stato
			, OperatoreId = @OperatoreId
			, OperatoreCognome = @OperatoreCognome
			, OperatoreNome = @OperatoreNome
			, OperatoreComputer = @OperatoreComputer
			, PazienteProvenienza = @PazienteProvenienza
			, PazienteIdProvenienza = @PazienteIdProvenienza
			, PazienteCognome = @PazienteCognome
			, PazienteNome = @PazienteNome
			, PazienteCodiceFiscale = @PazienteCodiceFiscale
			, PazienteDataNascita = @PazienteDataNascita
			, PazienteComuneNascitaCodice = @PazienteComuneNascitaCodice
			, PazienteNazionalitaCodice = @PazienteNazionalitaCodice
			, PazienteTessera = @PazienteTessera
			, MetodoAssociazione = @MetodoAssociazione
	WHERE Provenienza = @Provenienza
		AND IdProvenienza = @IdProvenienza
		AND Disattivato = 0
	

	SET @RowCount = @@ROWCOUNT
	IF @RowCount = 0
		BEGIN
			RAISERROR('Errore di nessun record inserito durante ConsensiMsgBaseUpdate!', 16, 1)
			GOTO ERROR_EXIT
		END

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec dbo.ConsensiNotificheAdd @Id, '0', @Utente
	IF @@ERROR <> 0
		BEGIN
			RAISERROR('Errore su SP ConsensiNotificheAdd durante ConsensiMsgBaseUpdate!', 16, 1)
			GOTO ERROR_EXIT
		END

	---------------------------------------------------
	-- MODIFICA ETTORE 2018-05-08: Inserisce record di notifica del paziente
	-- Il metodo di aggancio al consenso della DAE restituisce sempre il paziente ATTIVO
	---------------------------------------------------
	EXEC [dbo].[PazientiNotificheAdd] @IdPaziente , 8, @Utente 
	IF @@ERROR <> 0
		BEGIN
			RAISERROR('Errore su SP PazientiNotificheAdd durante [ConsensiMsgBaseInsert]!', 16, 1)
			GOTO ERROR_EXIT
		END

	---------------------------------------------------
	-- Completato
	---------------------------------------------------

	SELECT @RowCount AS ROW_COUNT
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	RETURN 1

	
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiMsgBaseUpdate] TO [DataAccessDll]
    AS [dbo];

