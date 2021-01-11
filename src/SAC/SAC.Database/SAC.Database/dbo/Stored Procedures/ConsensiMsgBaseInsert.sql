
-- =============================================
-- Author:		Pichierri
-- Create date: ???
-- Description:	Aggiunge un consenso 
-- Modify date: 2018-05-08 ETTORE: A seguito della modifica dei consesni del paziente eseguo anche una notifica paziente di tipo 8
-- =============================================
CREATE PROCEDURE [dbo].[ConsensiMsgBaseInsert]
	  @Utente varchar(64)
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
DECLARE @Id uniqueidentifier
DECLARE @DataInserimento datetime
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
		EXEC ConsensiEventiAccessoNegato @Utente, 0, 'ConsensiMsgBaseInsert', 'Utente non ha i permessi di scrittura!'

		RAISERROR('Errore di controllo accessi durante ConsensiMsgBaseInsert!', 16, 1)
		SELECT 1002 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------

	SET @Provenienza = dbo.LeggeConsensiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante ConsensiMsgBaseInsert!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	--  Verifico se c'è già
	---------------------------------------------------

	IF EXISTS( SELECT * FROM Consensi WHERE Provenienza=@Provenienza AND IdProvenienza=@IdProvenienza) 
		BEGIN
			SELECT 1 AS ROW_COUNT
			RETURN 0
		END

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	SET @Id = NewId()
	SET @DataInserimento = GetDate()
	SET @Disattivato = 0

	---------------------------------------------------
	--  Valuto il parametro @Tipo
	---------------------------------------------------	
	SELECT @IdTipo = Id FROM ConsensiTipo WHERE Nome = @Tipo

	---------------------------------------------------
	--  Inserisco
	---------------------------------------------------

	INSERT INTO Consensi
			( Id
			, DataInserimento
			, Disattivato
			, Provenienza
			, IdProvenienza
			, IdPaziente
			, IdTipo
			, DataStato
			, Stato		
			, OperatoreId
			, OperatoreCognome
			, OperatoreNome
			, OperatoreComputer
			, PazienteProvenienza
			, PazienteIdProvenienza
			, PazienteCognome
			, PazienteNome
			, PazienteCodiceFiscale
			, PazienteDataNascita
			, PazienteComuneNascitaCodice
			, PazienteNazionalitaCodice
			, PazienteTessera
			, MetodoAssociazione)
		VALUES
			( @Id
			, @DataInserimento
			, @Disattivato
			, @Provenienza
			, @IdProvenienza
			, @IdPaziente
			, @IdTipo
			, @DataStato
			, @Stato
			, @OperatoreId
			, @OperatoreCognome
			, @OperatoreNome
			, @OperatoreComputer
			, @PazienteProvenienza
			, @PazienteIdProvenienza
			, @PazienteCognome
			, @PazienteNome
			, @PazienteCodiceFiscale
			, @PazienteDataNascita
			, @PazienteComuneNascitaCodice
			, @PazienteNazionalitaCodice
			, @PazienteTessera
			, @MetodoAssociazione)

	SET @RowCount = @@ROWCOUNT
	IF @RowCount = 0
		BEGIN
			RAISERROR('Errore di nessun record inserito durante [ConsensiMsgBaseInsert]!', 16, 1)
			GOTO ERROR_EXIT
		END

	---------------------------------------------------
	-- Inserisce record di notifica per il flusso OUT dei consensi
	---------------------------------------------------
	exec dbo.ConsensiNotificheAdd @Id, '0', @Utente
	IF @@ERROR <> 0
		BEGIN
			RAISERROR('Errore su SP ConsensiNotificheAdd durante [ConsensiMsgBaseInsert]!', 16, 1)
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
    ON OBJECT::[dbo].[ConsensiMsgBaseInsert] TO [DataAccessDll]
    AS [dbo];

