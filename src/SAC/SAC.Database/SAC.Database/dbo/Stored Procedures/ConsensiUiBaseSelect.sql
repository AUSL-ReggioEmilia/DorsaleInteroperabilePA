




CREATE PROCEDURE [dbo].[ConsensiUiBaseSelect]
	@Id AS uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	SELECT    
		Consensi.Id
		, Consensi.DataInserimento
		, Consensi.Disattivato
		, Consensi.Provenienza
		, Consensi.IdProvenienza
		, Pazienti.Id AS IdPaziente
		, Consensi.IdTipo
		, ConsensiTipo.Nome AS Tipo
		, Consensi.DataStato
		, Consensi.Stato
		, Consensi.OperatoreId
		, Consensi.OperatoreCognome
		, Consensi.OperatoreNome
		, Consensi.OperatoreComputer
		, dbo.Pazienti.Provenienza AS PazienteProvenienza
		, dbo.Pazienti.IdProvenienza AS PazienteIdProvenienza
		, dbo.Pazienti.Cognome AS PazienteCognome
		, dbo.Pazienti.Nome AS PazienteNome
		, dbo.Pazienti.Tessera AS PazienteTessera
		, dbo.Pazienti.CodiceFiscale AS PazienteCodiceFiscale
		, dbo.Pazienti.DataNascita AS PazienteDataNascita
		, dbo.Pazienti.ComuneNascitaCodice AS PazienteComuneNascitaCodice
		, dbo.LookupIstatComuni(PazienteComuneNascitaCodice) AS PazienteComuneNascitaNome
		, dbo.Pazienti.NazionalitaCodice AS PazienteNazionalitaCodice
		, dbo.LookupIstatNazioni(PazienteNazionalitaCodice) AS PazienteNazionalitaNome
		, Consensi.Attributi
	FROM  
		dbo.Consensi 
		INNER JOIN dbo.ConsensiTipo 
			ON dbo.Consensi.IdTipo = dbo.ConsensiTipo.Id
		INNER JOIN dbo.Pazienti 
			ON dbo.Pazienti.Id = dbo.Consensi.IdPaziente
	WHERE 
		Consensi.Id = @Id		

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiUiBaseSelect] TO [DataAccessUi]
    AS [dbo];

