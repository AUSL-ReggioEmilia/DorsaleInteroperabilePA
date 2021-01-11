

CREATE PROCEDURE [dbo].[ConsensiUiBaseLista]
(
	@IdPaziente AS uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;

/*
	Fornisce tutti i consensi associati ap paziente @IdPaziente passato come parametro
	(cioè tutti i consensi di @IdPaziente e dei suoi figli), aggregati per trovare quelli
	di maggior validità ordinati per 
	
	Modifica Ettore 2014-05-23: 
		Ho restituito come IdPaziente L'IdPaziente passato come parametro cioè L'IdPaziente PADRE corrente
		In questo modo l'interfaccia web USER/ADMIN compone correttamente l'URL verso il dettaglio consenso
	
	MODIFICA ETTORE 2016-01-13: Gestione del nuovo campo XML Attributi
*/	
	DECLARE @ConsensiPaziente TABLE (Id UNIQUEIDENTIFIER, IdPaziente UNIQUEIDENTIFIER, IdTipo TINYINT, DataStato DATETIME, DataInserimento DATETIME, Disattivato TINYINT, Ordine INT, Livello INT, Attributi XML)

	INSERT INTO @ConsensiPaziente(Id , IdPaziente , IdTipo , DataStato , DataInserimento , Disattivato , Ordine, Livello, Attributi)
	SELECT 
		Consensi.Id	
		, Consensi.IdPaziente --questo è sempre l'IdPadre corrente
		, Consensi.IdTipo
		, Consensi.DataStato 
		, Consensi.DataInserimento	
		, Consensi.Disattivato
		, 0 AS Ordine
		, 0 AS Livello
		, Attributi
	FROM 
		Consensi 
	WHERE
		IdPaziente = @IdPaziente
	UNION ALL
	SELECT 
		Consensi.Id	
		--, Consensi.IdPaziente
		, @IdPaziente AS IdPaziente --restituisco sempre L'IdPadre corrente che è quello del parametro
		, Consensi.IdTipo
		, Consensi.DataStato 
		, Consensi.DataInserimento	
		, Consensi.Disattivato	
		, TAB.Id AS Ordine
		, TAB.Livello
		, Attributi
	FROM 
		[dbo].[GetTreeFusione](@IdPaziente) AS TAB
		inner join Consensi 
			ON Consensi.IdPaziente = TAB.IdFiglio

	--
	-- Ora li devo aggregare per tenere solo gli ultimi per tipo
	-- NON AGGREGO per IdPaziente in quanto i consensi dei figli è come se fossero consensi del padre 
	-- cioè fossero associati al paziente padre -> quindi il paziente è come se fosse lo stesso quindi 
	-- NON DEVO AGGREGARE!!! 
	--

	DECLARE @ConsensiPazienteAggregati TABLE (Id UNIQUEIDENTIFIER)
	INSERT INTO @ConsensiPazienteAggregati (Id)
	SELECT 
		Id 
	FROM @ConsensiPaziente C
		INNER JOIN (
			SELECT DISTINCT
				--C.IdPAziente, 
				C.DataStato, C.DataInserimento, C.IdTipo
			FROM 
				@ConsensiPaziente as C
				INNER JOIN (
					SELECT 
						--C.IdPAziente, 
						C.IdTipo, C.DataStato, Max(C.DataInserimento) AS DataInserimentoMax
					FROM 
						@ConsensiPaziente C 
						INNER JOIN 
						( 
							SELECT 
								--C.IdPaziente, 
								C.IdTipo, Max(C.DataStato) AS DataStatoMax
							FROM 
								@ConsensiPaziente C 
							WHERE 
								C.Disattivato = 0
							GROUP BY 
								--C.IdPaziente, 
								C.IdTipo
						) AS TAB1
						ON 
							--C.IdPAziente = TAB1.IdPAziente and 
							c.IdTipo = TAB1.IdTipo and C.DataStato = TAB1.DataStatoMax
					GROUP BY 
						--C.IdPAziente, 
						C.IdTipo, C.DataStato
				) AS TAB2 
				ON	--C.IdPAziente = TAB2.IdPAziente AND 
					C.DataStato = TAB2.DataStato
					AND C.dataInserimento = TAB2.DataInserimentoMax 
			GROUP BY
					--C.IdPAziente, 
					C.DataStato, C.DataInserimento, C.IdTipo
		) AS TAB3 
		ON --C.IdPaziente = TAB3.IdPaziente AND 
			C.DataStato = TAB3.DataStato
			AND C.DataInserimento = TAB3.DataInserimento
			AND C.IdTipo = TAB3.IdTipo

	--
	-- Restituisco
	--
	SELECT 
		C.Id
		, C.DataInserimento
		, C.Disattivato
		, C.Provenienza
		, C.IdProvenienza
		, P.Id AS IdPaziente
		, C.IdTipo
		, CT.Nome AS Tipo
		, C.DataStato
		, C.Stato
		, C.OperatoreId
		, C.OperatoreCognome
		, C.OperatoreNome
		, C.OperatoreComputer
		, P.Provenienza AS PazienteProvenienza
		, P.IdProvenienza AS PazienteIdProvenienza
		, P.Cognome AS PazienteCognome
		, P.Nome AS PazienteNome
		, P.Tessera AS PazienteTessera
		, P.CodiceFiscale AS PazienteCodiceFiscale
		, P.DataNascita AS PazienteDataNascita
		, P.ComuneNascitaCodice AS PazienteComuneNascitaCodice
		, dbo.LookupIstatComuni(P.ComuneNascitaCodice) AS PazienteComuneNascitaNome
		, P.NazionalitaCodice AS PazienteNazionalitaCodice
		, dbo.LookupIstatNazioni(P.NazionalitaCodice) AS PazienteNazionalitaNome
		, CP.Attributi AS Attributi
	FROM 
		@ConsensiPaziente AS CP 
		INNER JOIN @ConsensiPazienteAggregati AS CPA
			ON CP.Id = CPA.Id
		INNER JOIN Consensi AS C
			ON C.Id = CP.id
		INNER JOIN ConsensiTipo AS CT
			ON CT.Id = C.IdTipo
		INNER JOIN Pazienti AS P
			ON P.Id = CP.IdPaziente
	WHERE		
		C.Disattivato = 0
	ORDER BY 
		C.IdTipo

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiUiBaseLista] TO [DataAccessUi]
    AS [dbo];

