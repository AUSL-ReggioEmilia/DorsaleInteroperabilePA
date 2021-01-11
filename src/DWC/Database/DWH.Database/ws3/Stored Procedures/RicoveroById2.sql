


CREATE PROCEDURE [ws3].[RicoveroById2]
(
	@IdToken		UNIQUEIDENTIFIER
	, @IdRicovero	UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-16:
		ATTENZIONE:
		I dati restituiti nel campo "UltimoEventoDescr" NON POSSONO essere modificati in quanto utilizzati da una applicazione
		per descriminare fra ricoveri e liste di attesa

	CREATA VERSIONE 2 DA ETTORE 2016-10-17: Restituzione nuovi campi StatoCodice e StatoDescrizione al posto del campo Stato (equivalente a StatoDescrizione)
*/
	SET NOCOUNT ON
	--
	-- Verifico se al token è associato l'attibuto ATTRIB@VIEW_ALL
	--
	DECLARE @ViewAll as BIT=0
	IF EXISTS(SELECT * FROM dbo.OttieniRuoliAccessoPerToken(@IdToken) where Accesso = 'ATTRIB@VIEW_ALL')
		SET @ViewAll = 1
	--
	-- Ricavo l'Id del ruolo Role Manager associato al token
	--
	DECLARE @IdRuolo UNIQUEIDENTIFIER 
	SELECT @IdRuolo = IdRuolo FROM dbo.Tokens WHERE Id = @IdToken
	--
	-- Leggo il ricovero dalla tabella dei Ricoveri
	--
	SELECT
		R.Id
		, R.DataInserimento
		, R.DataModifica
		--NUOVO: Se ricovero o lista di attesa
		, R.Categoria
		, R.NumeroNosologico
		--Nuovo: NumeroNosologicoOrigine
		, R.NumeroNosologicoOrigine
		, R.AziendaErogante
		, R.SistemaErogante
		--Reparto di accettazione
		, R.RepartoAccettazioneCodice
		, R.RepartoAccettazioneDescr
		--Discrimino se il ricovero è in corso 
		, R.RepartoCorrenteCodice
		--Discrimino se il ricovero è in corso 			
		, R.RepartoCorrenteDescr
		, R.RepartoDimissioneCodice
		, R.RepartoDimissioneDescr
		, R.Diagnosi
		, R.TipoRicoveroCodice AS TipoEpisodioCodice
		, R.TipoRicoveroDescr AS TipoEpisodioDescr
		, R.DataAccettazione AS DataInizioEpisodio
		, R.DataTrasferimento
		, R.DataDimissione as DataFineEpisodio
		--
		-- Stato del ricovero (prima era UltimoEventoDescr) 
		-- se "ricovero":		Accettazione, Trasferimento, Dimissione, Riapertura 
		-- se "prenotazione":	Apertura, Chiusura
		--
		, R.StatoCodice
		, R.StatoDescrizione
	 	--
		-- IdPaziente
		--
		, dbo.GetPazienteAttivoByIdSac(R.IdPaziente) AS IdPaziente
	 	--
		-- Dati anagrafici del ricovero
		--
		, R.Cognome
		, R.Nome
		, R.CodiceFiscale
		, R.DataNascita
		, R.Sesso
		, R.ComuneNascita
		, R.CodiceSanitario
	FROM 
		ws3.Ricoveri AS R
	WHERE 
		--
		-- Filtro per Sistema e Oscuramenti
		--
		(
			(@ViewAll = 1) 
			OR 
			(
				EXISTS( SELECT * FROM [dbo].[OttieniSistemiErogantiPerToken](@IdToken) SE 
						WHERE   R.SistemaErogante = SE.SistemaErogante AND  R.AziendaErogante = SE.AziendaErogante)
				AND 
				([dbo].[CheckRicoveroOscuramenti](@IdRuolo, R.AziendaErogante, R.NumeroNosologico) = 1)
			)
		) 				
		AND Id = @IdRicovero
END