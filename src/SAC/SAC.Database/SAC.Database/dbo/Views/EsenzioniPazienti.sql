



-- =============================================
-- Author:      Ettore
-- Create date: 2014-05-23
-- Description: la vista restituisce tutti le esenzioni e nel campo IdPaziente restituisce l'Id dell'anagrafica padre
--		mentre nel campo IdPazienteFuso restitusce, nel caso che l'esenzione fosse associata ad una anagrafica figlia,
--		l'Id dell'anagrafica figlia.
-- Modify date: Simoneb - 2018-03-26, Restituito il campo Provenienza
-- =============================================

CREATE VIEW [dbo].[EsenzioniPazienti]
AS 

	SELECT       
		PE.Id
		-- Traslo l'IdPAziente fuso nel padre
		, P.Id AS IdPaziente
		-- Restituisco l'IdPazienteFuso (se attivo -> NULL)
		, NULL AS IdPazienteFuso 
		,PE.DataInserimento
		,PE.DataModifica
		,PE.Ts
		,PE.CodiceEsenzione
		,PE.CodiceDiagnosi
		,PE.Patologica
		,PE.DataInizioValidita
		,PE.DataFineValidita
		,PE.NumeroAutorizzazioneEsenzione
		,PE.NoteAggiuntive
		,PE.CodiceTestoEsenzione
		,PE.TestoEsenzione
		,PE.DecodificaEsenzioneDiagnosi
		,PE.AttributoEsenzioneDiagnosi
		,PE.Provenienza
		,PE.OperatoreId
		,PE.OperatoreCognome
		,PE.OperatoreNome
		,PE.OperatoreComputer	
	FROM PazientiEsenzioni AS PE WITH(NOLOCK)
		INNER JOIN Pazienti AS P WITH(NOLOCK)
		ON P.Id= PE.IdPaziente
	WHERE P.Disattivato = 0
	UNION 
	SELECT       
		PE.Id
		-- Traslo l'IdPAziente fuso nel padre
		, ISNULL(PF.IdPaziente, PE.IdPaziente) AS IdPaziente
		-- Restituisco l'IdPazienteFuso (se attivo -> NULL)
		, PF.IdPazienteFuso 
		,PE.DataInserimento
		,PE.DataModifica
		,PE.Ts
		,PE.CodiceEsenzione
		,PE.CodiceDiagnosi
		,PE.Patologica
		,PE.DataInizioValidita
		,PE.DataFineValidita
		,PE.NumeroAutorizzazioneEsenzione
		,PE.NoteAggiuntive
		,PE.CodiceTestoEsenzione
		,PE.TestoEsenzione
		,PE.DecodificaEsenzioneDiagnosi
		,PE.AttributoEsenzioneDiagnosi
		,PE.Provenienza
		,PE.OperatoreId
		,PE.OperatoreCognome
		,PE.OperatoreNome
		,PE.OperatoreComputer	
	FROM PazientiEsenzioni AS PE WITH(NOLOCK)
		INNER JOIN PazientiFusioni  AS PF WITH(NOLOCK)
		ON PE.IdPaziente = PF.IdPazienteFuso 
	WHERE PF.Abilitato = 1


