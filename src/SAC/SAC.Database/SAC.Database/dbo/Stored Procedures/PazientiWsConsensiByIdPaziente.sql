
CREATE PROCEDURE [dbo].[PazientiWsConsensiByIdPaziente]
(
	@Identity varchar(64),
	@IdPaziente uniqueidentifier
)
AS
BEGIN
/*
	Modifica Ettore 2014-05-14:
		Modifiato il codice per allinerae il comportamento alle altre SP
		Uso la nuova vista ConsesniSpResult che restituisce i consensi del blocco di fusione già raggruppati per ottenere i consesni più validi

	MODIFICA ETTORE 2016-01-11: Gestione del nuovo campo XML Attributi
		Il test di accesso è commentato perchè questa SP viene chiamata per creare dei dati figli, non esiste un metodo che la chiama direttamente
	
*/

	SET NOCOUNT ON;
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	--IF dbo.LeggeConsensiPermessiLettura(@Identity) = 0
	--BEGIN
	--	EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsConsensiByIdPaziente', 'Utente non ha i permessi di lettura!'

	--	RAISERROR('Errore di controllo accessi durante PazientiWsConsensiByIdPaziente!', 16, 1)
	--	RETURN
	--END

	---------------------------------------------------
	--  Traslo l'IdPaziente nell'attivo/root
	---------------------------------------------------
	SET @IdPaziente = dbo.GetPazienteRootByPazienteId(@IdPaziente)
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
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
		, dbo.WsGetAttributi(Attributi) AS Attributi
	FROM
		ConsensiSpResult
	WHERE
		IdPaziente = @IdPaziente
	ORDER BY
	 	IdTipo
	
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsConsensiByIdPaziente] TO [DataAccessWs]
    AS [dbo];

