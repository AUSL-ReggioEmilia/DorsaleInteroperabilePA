

CREATE VIEW [dbo].[ConsensiPazientiAggregati]
AS
/*
	Create da Ettore 2014-05-15: nuova vista per aggregare i consensi. 
	Restituisce per ogni paziente, tutti i tipi di consenso con Max(DataStato)	
	Inoltre se il consenso era associato ad una anagrafica figlia restituisce nel campo IdPazienteFuso
	l'Id dell'anagrafica figlia
	
	MODIFICA ETTORE 2016-01-12: gestione del nuovo campo Attributi
	MODIFICA ETTORE 2016-03-11: Tolta join più esterna e aggiunto in TAB2 parte join con IdTipo
*/
SELECT 
	C.Id
	,C.DataInserimento
	,C.DataDisattivazione
	,C.Disattivato
	,C.Provenienza
	,C.IdProvenienza
	--
	-- Questo è sempre l'id paziente attivo/padre (la ConsensiPaziente non fa altro che traslare l'IdPazienteFuso nel corrispondente padre)
	--
	, C.IdPaziente
	--
	-- Se <> NULL allora il consenso è associato ad una anagrafica figlia
	--
	, C.IdPazienteFuso
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
FROM 
	ConsensiPazienti C
	INNER JOIN 
	----------------TAB2
	(
		-- Ricavo: C.IdPaziente, C.IdTipo , DataStatoMax, -> DataInserimentoMax
		-- Metto distinct per sicurezza per restituire un solo record composta da [IdPaziente, IdTipo, DataStatoMax, DataInserimentoMax]
		SELECT DISTINCT
			C.IdPAziente, C.IdTipo, C.DataStato, MAX(C.DataInserimento) AS DataInserimentoMax
		FROM 
			ConsensiPazienti AS C 
			INNER JOIN 
			----------------TAB1
			( 
				-- Ricavo: C.IdPaziente, C.IdTipo con DataStatoMax
				SELECT 
					C.IdPaziente, C.IdTipo, MAX(C.DataStato) AS DataStatoMax
				FROM 
					ConsensiPazienti C 
				WHERE 
					C.Disattivato = 0
				GROUP BY C.IdPaziente, C.IdTipo
			) AS TAB1
			----------------
			ON C.IdPAziente = TAB1.IdPAziente and c.IdTipo = TAB1.IdTipo and C.DataStato = TAB1.DataStatoMax
			GROUP BY 
				C.IdPAziente, C.IdTipo, C.DataStato
	) AS TAB2 
	------------------
	ON C.IdPaziente = TAB2.IdPaziente 
	AND C.DataStato = TAB2.DataStato
	AND C.DataInserimento = TAB2.DataInserimentoMax
	AND C.IdTipo = TAB2.IdTipo

