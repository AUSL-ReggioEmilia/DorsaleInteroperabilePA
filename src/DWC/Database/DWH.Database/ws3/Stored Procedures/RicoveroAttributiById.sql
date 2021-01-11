

CREATE PROCEDURE [ws3].[RicoveroAttributiById]
(
	@IdRicovero UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-16
		Restituisce l'elenco degli attributi del ricovero/episodio @IdRicovero 
		Questa SP dev essere utilizzata solo per ricavare il dettaglio del ricovero
		Il controllo di accesso deve essere fatto sul record di testata del ricovero per questo motivo non c'è il parametro @IdToken
		GIA' PRESENTE IN WS2: Aggiunto il calcolo dell'attributo calcolato 'NumEpisodioDestinazione' in caso @IdRicovero di pronto soccorso
		
		MODIFICA ETTORE 2016-05-19: 
			Prima per calcolare la lista fusi + attivo era scritta cosi ma era molto lenta:
				INSERT INTO @TablePazienti(Id)
				SELECT Id
					FROM dbo.GetPazientiDaCercareByIdSac(dbo.GetPazienteAttivoByIdSac(@IdPaziente))	
			L'ho riscritta calcolando prima il paziente attivo e poi passandolo alla dbo.GetPazientiDaCercareByIdSac()
	
*/
	SET NOCOUNT ON;
	DECLARE @AziendaErogante VARCHAR(16) 	
	DECLARE @NumeroNosologico VARCHAR(64) 	
	DECLARE @TipoRicoveroCodice VARCHAR(16) 
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @StatoCodice TINYINT
	DECLARE @DataAccettazione DATETIME
	DECLARE @Datapartizione SMALLDATETIME
	DECLARE @NumeroNosologico_Dest VARCHAR(64) 
	--
	-- Calcolo informazioni sul ricovero corrente
	--
	SELECT
		@AziendaErogante = AziendaErogante
		, @NumeroNosologico = NumeroNosologico 
		, @TipoRicoveroCodice = TipoRicoveroCodice
		, @StatoCodice = StatoCodice
		, @DataPartizione = DataPartizione 
		, @IdPaziente = IdPaziente
		, @DataAccettazione = DataAccettazione
	FROM store.RicoveriBase 
	WHERE Id = @IdRicovero 
	----
	---- Se il ricovero corrente è di pronto soccorso nello stato di dimissione
	----
 	IF @TipoRicoveroCodice = 'P' and @StatoCodice = 3 --ProntoSoccorso e dimissione
	BEGIN
		--
		-- Lista dei fusi + l'attivo
		--
		-- MODIFICA ETTORE 2016-05-19: prima calcolo il paziente attivo e poi lo passo alla dbo.GetPazientiDaCercareByIdSac()
		--
		DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
		DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
		INSERT INTO @TablePazienti(Id)
			SELECT Id
			FROM dbo.GetPazientiDaCercareByIdSac(@IdPazienteAttivo)	
		--
		-- Cerco nell'attributo 'NumEpisodioOriginePS' quello con valore @NumeroNosologico
		--
		SELECT 
			@NumeroNosologico_Dest = NumeroNosologico 
		FROM 
			store.RicoveriBase AS RB WITH(NOLOCK)
			INNER JOIN @TablePazienti AS Pazienti
				ON RB.IdPaziente = Pazienti.Id
			INNER JOIN store.RicoveriAttributi AS RA WITH(NOLOCK)
				ON RB.Id = RA.IdRicoveriBase
					AND RB.DataPartizione = RA.DataPartizione
		WHERE 
			RA.Nome = 'NumEpisodioOriginePS' and RA.Valore = @NumeroNosologico
			AND RB.AziendaErogante = @AziendaErogante
			--La data di accettazione del ricovero di destinazione deve essere compresa fra (DataAccettazioneProntoSoccorso -1 giorno) e (DataAccettazioneProntoSoccorso + 6 giorni)
			AND RB.DataAccettazione between DATEADD(day, -1, @DataAccettazione) AND DATEADD(day, 6, @DataAccettazione) 
			AND RB.DataPartizione between DATEADD(day, -6, @DataPartizione) AND DATEADD(day, +6, @DataPartizione) 
			
	END
	
	--
	-- Eseguo union degli attributi su database con l'attributo 'NumEpisodioDestinazione' calcolato
	--	
	SELECT	
			IdRicoveriBase, 
			Nome,
			Valore
	FROM	
			store.RicoveriAttributi
	WHERE	
			IdRicoveriBase = @IdRicovero
			--AND NOT Nome IN (
			--	'CodiceAnagraficaCentrale', 'CodiceFiscale', 'CodiceSanitario', 'Cognome'
			--	, 'ComuneNascita', 'DataNascita', 'IdEsternoPaziente', 'Nome', 'NomeAnagraficaCentrale'
			--	, 'Sesso'
			--	)
	UNION
	SELECT	
			@IdRicovero
			, 'NumEpisodioDestinazione'
			, @NumeroNosologico_Dest
	WHERE NOT @NumeroNosologico_Dest IS NULL

END