





-- =============================================
-- Author:		Ettore
-- Create date: 2016-03-17
-- Description:	Restituisce la testata di dettaglio del ricovero
--				ETTORE 2016-10-17 Restituzione nuovi campi StatoCodice e StatoDescrizione al posto del campo Stato (equivalente a StatoDescrizione)		
-- Modify date: 2019-01-07 - ETTORE: 
--		Se @AziendaErogante non è specificato restituisce il primo ricovero creato con il nosologico @NumeroNosologico
--		I nosologici dovrebbero essere distinti per @AziendaErogante tranne nel caso dei ricoveri specchio: 
--		in tale caso si restituisce il primo ricovero creato
-- =============================================
CREATE PROCEDURE [ws3].[RicoveroByNosologico2]
(
	@IdToken UNIQUEIDENTIFIER
	, @NumeroNosologico varchar(64)
	, @AziendaErogante as varchar(16)
)
AS
BEGIN
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
	-- Se @AziendaErogante è NULL o '' la valorizzo con  NULL
	--
	IF ISNULL(@AziendaErogante,'') = ''
		SET @AziendaErogante = NULL

	--
	-- Leggo il ricovero dalla tabella dei Ricoveri
	--
	SELECT TOP 1 
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
		AND R.NumeroNosologico = @NumeroNosologico 
		AND (R.AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL) 
	--
	-- Eventualmente restituisco il primo ricovero creato (per ADT Specchio)
	--
	ORDER BY DataInserimento ASC 


END