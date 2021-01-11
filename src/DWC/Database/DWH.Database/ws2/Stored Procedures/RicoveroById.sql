

CREATE PROCEDURE [ws2].[RicoveroById]
(
	@IdRicovero uniqueidentifier --identifica il record di accettazione
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2RicoveroById
		Restituito il campo XML Oscuramenti
		Aggounto il SistemaErogante
		In seguito a gestione "prenotazioni" modificato il codice che restituisce il campo "UltimoEventoDescr"

	ATTENZIONE:
	I dati restituiti nel campo "UltimoEventoDescr" NON POSSONO essere modificati in quanto utilizzati da una applicazione
	per descriminare fra ricoveri e liste di attesa
*/
	SET NOCOUNT ON
	--
	-- Leggo il ricovero dalla tabella dei Ricoveri
	--
	SELECT
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
		Id = @IdRicovero
	
	RETURN @@ERROR

END



