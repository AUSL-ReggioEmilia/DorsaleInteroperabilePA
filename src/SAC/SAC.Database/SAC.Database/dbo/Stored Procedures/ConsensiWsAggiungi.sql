



CREATE PROCEDURE [dbo].[ConsensiWsAggiungi]
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
		Non lo converto nel formato interno perchè lo fa la SP dbo.ConsensiWsBaseInsert

*/

---------------------------------------------------
-- Variabili
---------------------------------------------------
DECLARE @Id uniqueidentifier
DECLARE @IdTipo tinyint

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggeConsensiPermessiScrittura(@Identity) = 0
	BEGIN
		EXEC ConsensiEventiAccessoNegato @Identity, 0, 'ConsensiWsAggiungi', 'Utente non ha i permessi di scrittura!'

		RAISERROR('Errore di controllo accessi durante ConsensiWsAggiungi!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	SET @Id = NewId()

	---------------------------------------------------
	--  Valuto il parametro @Tipo
	---------------------------------------------------
	SELECT @IdTipo = Id FROM ConsensiTipo WHERE Nome = @Tipo

	EXEC dbo.ConsensiWsBaseInsert @Identity, @Id, @IdProvenienza, @IdPaziente, @IdTipo, 
									@DataStato, @Stato, @OperatoreId, @OperatoreCognome, @OperatoreNome, 
									@OperatoreComputer, @PazienteProvenienza, @PazienteIdProvenienza, 
									@PazienteCognome, @PazienteNome, @PazienteCodiceFiscale, @PazienteDataNascita, 
									@PazienteComuneNascitaCodice, @PazienteNazionalitaCodice, @PazienteTessera,	
									@MetodoAssociazione, @Attributi 
	

	SELECT @Id AS Id
	
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiWsAggiungi] TO [DataAccessWs]
    AS [dbo];

