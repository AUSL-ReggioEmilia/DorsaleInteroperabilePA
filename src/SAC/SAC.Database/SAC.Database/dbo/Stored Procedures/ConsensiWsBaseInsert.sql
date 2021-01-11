


CREATE PROCEDURE [dbo].[ConsensiWsBaseInsert]
	  @Utente AS varchar(64)
	
	, @Id uniqueidentifier
	, @IdProvenienza varchar(64)
	, @IdPaziente uniqueidentifier
	, @IdTipo tinyint
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
	, @Attributi XML = NULL
	
AS
BEGIN
/*

	MODIFICA ETTORE 2016-01-11: gestione nuovo campo XML Attributi
	Il parametro @Attributi viene passato come:
		<Attributi xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://sac.org/Types">
		  <Attributo>
			<Nome>Nome1</Nome>
			<Valore>Valore1</Valore>
		  </Attributo>
		  <Attributo>
			<Nome>Nome2</Nome>
			<Valore>Valore2</Valore>
		  </Attributo>
		</Attributi>	
	
	Poi gli attributi vengono salvati nel formato:
	<Attributi>
		<Attributo Nome="Nome1" Valore="Valore1" />
		<Attributo Nome="Nome2" Valore="Valore2" />
	</Attributi>	
	
	MODIFICA ETTORE 2018-05-08: Inserisce record di notifica del paziente
	MODIFICA ETTORE 2018-06-08: Mi assicurao di notificare il paziente attivo
*/

DECLARE @DataInserimento AS datetime
DECLARE @Provenienza varchar(16)
DECLARE @Disattivato AS tinyint

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Calcolo provenienza da Identity
	---------------------------------------------------

	SET @Provenienza = dbo.LeggeConsensiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante ConsensiWsBaseInsert!', 16, 1)
		RETURN
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
	-- Parsing del campo attributi: @Attributi -> @AttributiConsenso
	---------------------------------------------------
	DECLARE @AttributiConsenso XML
	DECLARE @TableAttributi table (Nome varchar(128), Valore varchar(MAX))
	IF @Attributi IS NOT NULL
	BEGIN
		INSERT INTO @TableAttributi (Nome, Valore)
		SELECT	Attributo.Col.value('declare namespace s="http://sac.org/Types"; s:Nome[1]','varchar(128)') AS Nome,
				Attributo.Col.value('declare namespace s="http://sac.org/Types"; s:Valore[1]','varchar(MAX)') AS Valore
			FROM @Attributi.nodes('declare namespace s="http://sac.org/Types"; /s:Attributi/s:Attributo') Attributo(Col)
			
	END
	IF EXISTS (SELECT * FROM @TableAttributi)
	BEGIN
		-- Converto nella struttura stadard di output del DWH
		SET @AttributiConsenso = CONVERT(XML, (SELECT Nome, Valore
											FROM @TableAttributi Attributo
											FOR XML AUTO, ROOT('Attributi')
											)
									)
	END

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	IF @Id IS NULL SET @Id = NewId()
	SET @DataInserimento = GetDate()
	SET @Disattivato = 0
	
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
			, MetodoAssociazione
			, Attributi)
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
			, @MetodoAssociazione
			, @AttributiConsenso)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec dbo.ConsensiNotificheAdd @Id, '2', @Utente

	---------------------------------------------------
	-- MODIFICA ETTORE 2018-05-08: Inserisce record di notifica del paziente
	---------------------------------------------------
	--Mi assicuro che sia il paziente attivo
	SELECT @IdPaziente = [dbo].[GetPazienteRootByPazienteId] (@IdPaziente)
	EXEC [dbo].[PazientiNotificheAdd] @IdPaziente , 8, @Utente 
	
	COMMIT	
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	RETURN 1

END


GO


