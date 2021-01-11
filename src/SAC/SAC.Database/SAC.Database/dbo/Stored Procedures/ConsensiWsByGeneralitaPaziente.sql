



CREATE PROCEDURE [dbo].[ConsensiWsByGeneralitaPaziente]
(
	@Identity varchar(64),
	@Cognome varchar(64),
	@Nome varchar(64),
	@DataNascita as datetime,
	@ComuneNascitaCodice varchar(6)
)
AS
BEGIN
/*
	Modifica Ettore 2014-05-14:
		Sostituito il nome della vista ConsensiOutputResult con ConsensiSpResult. 
		Inoltre la vista ConsensiSpResult restituisce i consensi del blocco di fusione già raggruppati per ootenere i consensi "più validi"

	MODIFICA ETTORE 2016-01-11: Getsione del nuovo campo XML Attributi								
*/
	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggeConsensiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC ConsensiEventiAccessoNegato @Identity, 0, 'ConsensiCercaByGeneralitaPaziente', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante ConsensiCercaByGeneralitaPaziente!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	DECLARE @IdPaziente uniqueidentifier
	SELECT TOP 1 @IdPaziente = Id 
	FROM Pazienti 
	WHERE Cognome = @Cognome AND Nome = @Nome AND DataNascita = @DataNascita AND ComuneNascitaCodice = @ComuneNascitaCodice
	ORDER BY LivelloAttendibilita DESC, DataModifica DESC
	
	SET @IdPaziente = dbo.GetPazienteRootByPazienteId(@IdPaziente) 

	SELECT
		  Id
		, Provenienza
		, IdProvenienza
		, IdPaziente
		, Tipo
		, DataStato
		, Stato
		, OperatoreId
		, OperatoreCognome
		, OperatoreNome
		, OperatoreComputer
		, PazienteCognome
		, PazienteNome
		, PazienteTessera
		, PazienteCodiceFiscale
		, PazienteDataNascita
		, PazienteComuneNascitaCodice
		, PazienteComuneNascitaNome
		, PazienteNazionalitaCodice
		, PazienteNazionalitaNome
		--Converto l'xml degli attributi come se lo aspettano i WS
		, dbo.WsGetAttributi(Attributi) AS Attributi
	FROM 
		ConsensiSpResult

	WHERE (PazienteCognome = @Cognome)
		AND (PazienteNome = @Nome)
		AND (PazienteDataNascita = @DataNascita)
		AND (PazienteComuneNascitaCodice = @ComuneNascitaCodice)
	OR IdPaziente = @IdPaziente 

END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiWsByGeneralitaPaziente] TO [DataAccessWs]
    AS [dbo];

