
CREATE VIEW [dbo].[ConsensiPazienti]
AS 
/*
	Creata da Ettore 2014-05-15: 
		la vista restituisce tutti i consensi e nel campo IdPaziente restituisce l'Id dell'anagrafica padre
		mentre nel campo IdPazienteFuso restitusce, nel caso che il consenso fosse associato ad una anagrafica figlia,
		l'Id dell'anagrafica figlia.
		
	MODIFICA ETTORE 2016-01-12: gestione del nuovo campo Attributi
*/
	SELECT 
	  C.Id
      ,C.DataInserimento
      ,C.DataDisattivazione
      ,C.Disattivato
      ,C.Provenienza
      ,C.IdProvenienza
      -- l'IdPAziente dell' attivo
      , P.Id AS IdPaziente
      -- Restituisco l'IdPazienteFuso (se attivo -> NULL)
      , NULL AS IdPazienteFuso 
      ,C.IdTipo
      ,C.DataStato
      ,C.Stato
      ,C.OperatoreId
      ,C.OperatoreCognome
      ,C.OperatoreNome
      ,C.OperatoreComputer
      ,C.PazienteProvenienza
      ,C.PazienteIdProvenienza
      ,C.PazienteCognome
      ,C.PazienteNome
      ,C.PazienteCodiceFiscale
      ,C.PazienteDataNascita
      ,C.PazienteComuneNascitaCodice
      ,C.PazienteNazionalitaCodice
      ,C.PazienteTessera
      ,C.MetodoAssociazione		
      ,C.Attributi
	FROM Consensi  AS C WITH(NOLOCK)
		INNER JOIN Pazienti AS P WITH(NOLOCK)
		ON C.IdPaziente = P.Id
			
	WHERE 
		P.Disattivato= 0 AND C.Disattivato = 0
	UNION ALL	
	SELECT 
	  C.Id
      ,C.DataInserimento
      ,C.DataDisattivazione
      ,C.Disattivato
      ,C.Provenienza
      ,C.IdProvenienza
      -- Traslo l'IdPAziente fuso nel padre
      , ISNULL(PF.Idpaziente, C.IdPaziente) AS IdPaziente
      -- Restituisco l'IdPazienteFuso (se attivo -> NULL)
      , PF.IdPazienteFuso 
      ,C.IdTipo
      ,C.DataStato
      ,C.Stato
      ,C.OperatoreId
      ,C.OperatoreCognome
      ,C.OperatoreNome
      ,C.OperatoreComputer
      ,C.PazienteProvenienza
      ,C.PazienteIdProvenienza
      ,C.PazienteCognome
      ,C.PazienteNome
      ,C.PazienteCodiceFiscale
      ,C.PazienteDataNascita
      ,C.PazienteComuneNascitaCodice
      ,C.PazienteNazionalitaCodice
      ,C.PazienteTessera
      ,C.MetodoAssociazione		
	  ,C.Attributi
	FROM Consensi  AS C WITH(NOLOCK)
	INNER JOIN PazientiFusioni  AS PF WITH(NOLOCK)
		ON C.IdPaziente = PF.IdPazienteFuso 
	WHERE 
		PF.Abilitato = 1
		AND C.Disattivato = 0


