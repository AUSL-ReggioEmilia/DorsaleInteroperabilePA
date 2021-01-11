


-- =============================================
-- Author:		SimoneB
-- Create date: 2018-05-17
-- Description:	Creata la procedura di inserimento di un consenso basato solo su IdPaziente.
-- =============================================
CREATE PROCEDURE [pazienti_ws].[ConsensiAggiungi2]
(
	  @Identity varchar(64)
	, @IdProvenienza varchar(64)
	, @IdPaziente uniqueidentifier
	, @Tipo varchar(64)
	, @DataStato datetime
	, @Stato bit
	, @OperatoreId varchar(64)
	, @OperatoreCognome varchar(64)
	, @OperatoreNome varchar(64)
	, @OperatoreComputer varchar(64)
	, @MetodoAssociazione varchar(32)
	, @Attributi XML = NULL
)
AS
BEGIN
/*	
	GLI ATTRIBUTI VENGONO SALVATI NEL FORMATO:
		<Attributi>
			<Attributo Nome="Nome1" Valore="Valore1" />
			<Attributo Nome="Nome2" Valore="Valore2" />
		</Attributi>	
*/

	DECLARE @Id uniqueidentifier = NewId()
	DECLARE @IdTipo tinyint = NULL
	DECLARE @DataInserimento AS datetime = GetDate()
	DECLARE @Provenienza varchar(16)
	DECLARE @Disattivato AS tinyint = 0

	DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)

BEGIN TRY

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	IF dbo.LeggeConsensiPermessiScrittura(@Identity) = 0
	BEGIN
		EXEC dbo.ConsensiEventiAccessoNegato @Identity, 0, @ProcName, 'Utente non ha i permessi di scrittura!'
		RAISERROR('Errore di controllo accessi!', 16, 1)
		RETURN
	END
		
	---------------------------------------------------
	-- Calcolo provenienza da Identity
	---------------------------------------------------
	SET @Provenienza = dbo.LeggeConsensiProvenienza(@Identity)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore Provenienza non trovata!', 16, 1)
		RETURN
	END
	
	---------------------------------------------------
	--  Lookup del Tipo consenso
	---------------------------------------------------
	SELECT @IdTipo = Id FROM dbo.ConsensiTipo WHERE Nome = @Tipo
	IF @IdTipo IS NULL
	BEGIN
		RAISERROR('Errore Tipo consenso non trovato!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Verifico se il consenso c'è già
	---------------------------------------------------
	IF EXISTS (SELECT 1 FROM dbo.Consensi 
				WHERE Provenienza=@Provenienza 
				AND IdProvenienza=@IdProvenienza
				AND Disattivato=0)
	BEGIN
		SELECT 
		 Id	
		,Provenienza
		,IdProvenienza
		,IdPaziente
		,@Tipo as Tipo
		,DataStato
		,Stato		
		,OperatoreId
		,OperatoreCognome
		,OperatoreNome
		,OperatoreComputer		
		,Attributi
		FROM dbo.Consensi 
		WHERE Provenienza=@Provenienza 
			AND IdProvenienza=@IdProvenienza 
			AND Disattivato=0
	
		RETURN
	END
	

	DECLARE @PazienteProvenienza varchar(16)
	, @PazienteIdProvenienza varchar(64)
	, @PazienteCognome varchar(64)
	, @PazienteNome varchar(64)
	, @PazienteCodiceFiscale varchar(16)
	, @PazienteDataNascita datetime
	, @PazienteComuneNascitaCodice varchar(6)
	, @PazienteNazionalitaCodice varchar(3)
	, @PazienteTessera varchar(16)

	--
	--Ottengo i dati del paziente.
	--
	SELECT @PazienteProvenienza = Provenienza
			,@PazienteIdProvenienza = IdProvenienza
			,@PazienteCognome = Cognome
			,@PazienteNome = Nome
			,@PazienteCodiceFiscale = CodiceFiscale
			,@PazienteDataNascita = DataNascita
			,@PazienteComuneNascitaCodice = ComuneNascitaCodice
			,@PazienteNazionalitaCodice = NazionalitaCodice
			,@PazienteTessera = Tessera
	FROM dbo.Pazienti
	WHERE id = @IdPaziente

	--
	--Verifico che il paziente esista.
	--
	IF @PazienteProvenienza IS NULL
	 BEGIN
	 	DECLARE @msgPazienteMancante VARCHAR(256)= 'Il paziente con id ' + CAST(@IdPaziente AS VARCHAR(40)) + ' non esiste.'
	 	RAISERROR(@msgPazienteMancante, 16, 1)
		RETURN
	 END


	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------
	BEGIN TRAN

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------
	INSERT INTO dbo.Consensi
	(	  Id
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
		, MetodoAssociazione
		, Attributi
	)
	OUTPUT
		  INSERTED.Id
		, INSERTED.Provenienza
		, INSERTED.IdProvenienza
		, INSERTED.IdPaziente
		, @Tipo as Tipo
		, INSERTED.DataStato
		, INSERTED.Stato
		, INSERTED.OperatoreId
		, INSERTED.OperatoreCognome
		, INSERTED.OperatoreNome
		, INSERTED.OperatoreComputer
		, INSERTED.Attributi
	VALUES
	(	  @Id
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
		, @MetodoAssociazione
		, @Attributi
	)

	---------------------------------------------------
	-- Inserisce record di notifica per il flusso OUT dei consensi
	---------------------------------------------------
	EXEC dbo.ConsensiNotificheAdd @Id, '2', @Identity

	---------------------------------------------------
	-- MODIFICA ETTORE 2018-05-08: Inserisce record di notifica OUT del paziente
	---------------------------------------------------
	--Mi assicuro che sia il paziente attivo
	SELECT @IdPaziente = [dbo].[GetPazienteRootByPazienteId] (@IdPaziente)
	EXEC [dbo].[PazientiNotificheAdd] @IdPaziente , 8, @Identity 

	
	COMMIT	
		
END TRY
BEGIN CATCH

	---------------------------------------------------
	--     ROLLBACK TRANSAZIONE
	---------------------------------------------------
	IF @@TRANCOUNT > 0 ROLLBACK

	---------------------------------------------------
	--     GESTIONE ERRORI (LOG E PASSO FUORI)
	---------------------------------------------------
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE()    
	EXEC dbo.PazientiEventiAvvertimento @Identity, 0, @ProcName, @msg
	-- PASSO FUORI L'ECCEZIONE
	;THROW;

END CATCH

	
END