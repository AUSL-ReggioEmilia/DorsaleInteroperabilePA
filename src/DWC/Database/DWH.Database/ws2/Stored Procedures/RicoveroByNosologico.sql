


-- =============================================
-- Author:		Ettore
-- Create date: 2015-05-22
-- Description:	Restituisce la testata di dettaglio del ricovero
-- Modify date: 2019-01-07 - ETTORE: 
--		Se @AziendaErogante non è specificato restituisce il primo ricovero creato con il nosologico @NumeroNosologico
--		I nosologici dovrebbero essere distinti per @AziendaErogante tranne nel caso dei ricoveri specchio: 
--		in tale caso si restituisce il primo ricovero creato
-- =============================================
CREATE PROCEDURE [ws2].[RicoveroByNosologico]
(
	@NumeroNosologico varchar(64),
	@AziendaErogante as varchar(16)
)
AS
BEGIN
	SET NOCOUNT ON

/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RicoveroByNosologico
		Restituito il campo XML Oscuramenti
		Aggiunto il SistemaErogante

	In seguito a gestione "prenotazioni" modificato il codice che restituisce il campo "UltimoEventoDescr"
	
	ATTENZIONE:
	I dati restituiti nel campo "UltimoEventoDescr" NON POSSONO essere modificati in quanto utilizzati da una applicazione
	per descriminare fra ricoveri e liste di attesa
*/

	--
	-- Se @AziendaErogante è NULL o '' la valorizzo con  NULL
	--
	IF ISNULL(@AziendaErogante,'') = ''
		SET @AziendaErogante = NULL

	--
	-- Leggo il ricovero dalla tabella dei Ricoveri
	--
	SELECT TOP 1 
		--
		-- Id del ricovero
		--
		Id 
		--MODIFICA ETTORE 2012-09-07: traslazione id paziente nell'id paziente attivo
		,dbo.GetPazienteAttivoByIdSac(IdPaziente) AS IdPaziente
		,NumeroNosologico
		,AziendaErogante
		,SistemaErogante
		,CAST( ISNULL(RepartoAccettazioneDescr,'') + ISNULL(NULLIF('(' + RepartoAccettazioneCodice + ')','()'), '') AS VARCHAR(128)) 
			AS RepartoRicoveroAccettazioneDescr
		,CASE WHEN DataDimissione IS NULL THEN
			CAST( ISNULL(RepartoDescr,'') + 
					ISNULL( NULLIF( '(' + RepartoCodice + ')' , '()') , '') AS VARCHAR(128))		
		ELSE
			''
		END AS RepartoRicoveroUltimoEventoDescr
		,Diagnosi
		,CAST(ISNULL(TipoRicoveroDescr,'') AS VARCHAR(128)) AS TipoEpisodioDescr

		,DataAccettazione AS DataInizioEpisodio
		,DataDimissione AS DataFineEpisodio
		--
		-- Descrizione dell'ultimo evento: 
		-- se "ricovero":		Accettazione, Trasferimento, Dimissione, Riapertura 
		-- se "prenotazione":	Apertura, Chiusura
		--
		,CASE 
			WHEN StatoCodice IN (0,1,2,3,4) THEN
				CASE WHEN StatoCodice = 2 THEN
					CAST('Trasferimento' AS VARCHAR(64))
				ELSE
					CAST(ISNULL(StatoDescr,'') AS VARCHAR(64))
				END
			WHEN StatoCodice IN (20,21,23) THEN --Prenotazione Aperta
				CAST('Apertura' AS VARCHAR(64))
			WHEN StatoCodice IN (22,24) THEN --Prenotazione Chiusa
				CAST('Chiusura' AS VARCHAR(64))
			ELSE
				CAST('' AS VARCHAR(64))
	 		END AS UltimoEventoDescr
		--
		-- Restituisco XML col lista degli oscuramenti
		--
		,Oscuramenti
	FROM 
		ws2.Ricoveri
	WHERE 
		NumeroNosologico = @NumeroNosologico 
		AND (AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
	--
	-- Eventualmente restituisco il primo ricovero creato (per ADT Specchio)
	--
	ORDER BY DataInserimento ASC 
	
	RETURN @@ERROR

END

