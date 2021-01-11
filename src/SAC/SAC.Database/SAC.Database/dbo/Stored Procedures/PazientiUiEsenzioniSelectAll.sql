

CREATE PROCEDURE [dbo].[PazientiUiEsenzioniSelectAll]
(
	  @IdPaziente AS uniqueidentifier
	, @DataFineValidita as datetime
)
AS
BEGIN
	SET NOCOUNT ON;
	/*
		Modifica Ettore 2014-05-23: 
			Prima restituiva le esenzioni associate all'IdPaziente passato come parametro
			Ora restituisce il blocco delle esenzioni associate alla catena di fusione dell'IdPaziente passato come parametro
			
		Modifica Ettore 2015-07-27: Visualizzazione delle esenzioni con DataFineValidita NULL
	*/	
	DECLARE @EsenzioniPaziente TABLE (Id UNIQUEIDENTIFIER, IdPaziente UNIQUEIDENTIFIER)

	INSERT INTO @EsenzioniPaziente(Id, IdPaziente)
	SELECT 
		Id
		, IdPaziente
	FROM 
		PazientiEsenzioni
	WHERE
		IdPaziente = @IdPaziente
	UNION 
	SELECT 
		PazientiEsenzioni.Id
		--, PazientiEsenzioni.IdPaziente
		, @IdPaziente AS IdPAziente --restituisco il padre della catena di fusione richiesta
	FROM 
		[dbo].[GetTreeFusione](@IdPaziente) AS TAB
		inner join PazientiEsenzioni
			ON PazientiEsenzioni.IdPaziente = TAB.IdFiglio

	--
	-- A questo punto la tabella @EsenzioniPaziente contiene tutte le esenzioni associate all'IdPadre @IdPaziente
	--
	SELECT 
           PER.Id
           ,EP.IdPaziente
           ,PER.DataInserimento
           ,PER.DataModifica
           ,PER.CodiceEsenzione
           ,PER.CodiceDiagnosi
           ,PER.Patologica
           ,PER.DataInizioValidita
           ,PER.DataFineValidita
           ,PER.NumeroAutorizzazioneEsenzione
           ,PER.NoteAggiuntive
           ,PER.CodiceTestoEsenzione
           ,PER.TestoEsenzione
           ,PER.DecodificaEsenzioneDiagnosi
           ,PER.AttributoEsenzioneDiagnosi
	FROM 
		PazientiUiEsenzioniResult AS PER
		INNER JOIN @EsenzioniPaziente AS EP 
			ON EP.Id = PER.id
	WHERE 
		(
			PER.DataFineValidita IS NULL --Modifica Ettore 2014-05-23: Per visualizzare anche le esenzioni con DataFineValidita NULL
			OR (PER.DataFineValidita >= @DataFineValidita
		) 
		--
		-- quando l'interfaccia passa @DataFineValidita=NULL significa che la SP deve restituire tutte le esenzioni 
		-- a prescindere dalla data di fine validità, quindi anche quelle scadute
		--
		OR (@DataFineValidita IS NULL)) 
	ORDER BY
		PER.DataFineValidita DESC
		
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiEsenzioniSelectAll] TO [DataAccessUi]
    AS [dbo];

