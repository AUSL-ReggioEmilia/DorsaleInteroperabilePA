
CREATE PROCEDURE [ws3].[PazienteEsenzioniById]
(
	@IdPaziente UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-25:
	Ricava i dati di esenzioni valide del paziente per il dettaglio paziente

	MODIFICATA SANDRO 2016-05-12: Usa nuova vista [sac].[PazientiEsenzioni]
*/
	SET NOCOUNT ON;

	DECLARE @DataOggi DATETIME
	SET @DataOggi = CAST(CONVERT(VARCHAR(10), GETDATE(), 120) AS DATETIME)

	--			
	-- Traslo l'idpaziente nell'idpaziente attivo			
	--
	SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)

	SELECT 
		@IdPaziente AS IdPaziente
		, CodiceEsenzione AS EsenzioneCodice
		, DataInizioValidita 
		, DataFineValidita
		, Patologica			
		, NumeroAutorizzazioneEsenzione AS EsenzioneNumeroAutorizzazione
		, CodiceTestoEsenzione AS EsenzioneCodiceTesto
		, TestoEsenzione AS EsenzioneTesto
		, CodiceDiagnosi AS DiagnosiEsenzioneCodice
		, DecodificaEsenzioneDiagnosi AS DiagnosiEsenzioneDecodifica
		, AttributoEsenzioneDiagnosi AS DiagnosiEsenzioneAttributo			
		, NoteAggiuntive
	FROM 
		[sac].[PazientiEsenzioni]
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti Pazienti
			ON PazientiEsenzioni.IdPazienti = Pazienti.Id				
	WHERE 
		(DataInizioValidita <= @DataOggi AND @DataOggi <= ISNULL(DataFineValidita, @DataOggi))
	ORDER BY
		DataInizioValidita 
END