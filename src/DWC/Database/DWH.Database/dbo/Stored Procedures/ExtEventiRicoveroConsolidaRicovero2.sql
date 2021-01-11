
-- =============================================
-- Author:		ETTORE
-- Create date: 2019-05-24
-- Description:	Consolidamento del record del RICOVERO in base agli eventi ADT
-- Modify date: 2020-03-30 - ETTORE: eliminato il try catch cosi errore SQL arriva direttamente alla DAE
--									 e tolto nel codice della DAE il test reader.HasRow() perchè la 
--									 segnalazione dell'eccezione avviene in fase di lettura del reader.
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiRicoveroConsolidaRicovero2]
(
	@AziendaErogante	AS VARCHAR(16)
	, @NumeroNosologico AS VARCHAR(64) 
	, @RicoveroEsiste	AS BIT --la DAE mi dice già se il record del ricovero per azienda-nosologico esiste (evito di fare nuova query in SQL)
	, @TipoEventoCodice AS VARCHAR(16) --la DAE mi dice già il tipo di evento corrente: evito di fare nuova query in SQL per determinare se evento E o X
)
AS
BEGIN
	SET @TipoEventoCodice = UPPER(@TipoEventoCodice)
	IF @TipoEventoCodice IN ('E', 'X') AND @RicoveroEsiste = 1
	BEGIN 
		--
		-- Restituisco i dati presenti sul record del ricovero.
		-- Solo il campo StatoCOdice e la DataModificaEsterno li ricavo dall'insieme degli eventi ADT
		--
		SELECT  TOP 1 
		dbo.GetRicoveroStatoCodice(AziendaErogante, NumeroNosologico) AS StatoCodice
		--Leggo dal blocco degli eventi la max DataModificaEsterno
		,(SELECT MAX(DataModificaEsterno) FROM store.EventiBase WHERE AziendaErogante = @AziendaERogante 
			AND NumeroNosologico = @NumeroNosologico 
			) 
		AS DataModificaEsterno
		-- Gli altri dati li restituisco cosi come sono attualmente sul record del ricovero
		,NumeroNosologico
		,AziendaErogante
		,RepartoErogante
		,IdPaziente
		,OspedaleCodice
		,ISNULL(OspedaleDescr, '') AS OspedaleDescr
		,TipoRicoveroCodice 
		,TipoRicoveroDescr
		,Diagnosi
		,DataAccettazione
		,RepartoAccettazioneCodice
		,RepartoAccettazioneDescr

		,DataTrasferimento
		,RepartoCodice
		,RepartoDescr
		,SettoreCodice
		,SettoreDescr
		,LettoCodice
		,DataDimissione
		FROM 
			store.RicoveriBase
		WHERE
			AziendaErogante = @AziendaERogante
			AND NumeroNosologico = @NumeroNosologico

		IF @@ERROR <> 0 GOTO ERROR_EXIT

	END
	ELSE
	BEGIN
		--
		-- Calcolo i dati del ricovero dagli eventi ADT
		--
		SELECT  TOP 1 
			--
			-- NUOVO CAMPO
			--
			dbo.GetRicoveroStatoCodice(AziendaErogante, NumeroNosologico) AS StatoCodice
			,(SELECT MAX(DataModificaEsterno) FROM store.EventiBase WHERE AziendaErogante = @AziendaERogante 
				AND NumeroNosologico = @NumeroNosologico 
				--AND SistemaErogante = 'ADT'
				) 
			AS DataModificaEsterno
			,NumeroNosologico
			,AziendaErogante
			--,NUOVA FUNZIONE AS RepartoErogante
			,dbo.GetRicoveroRepartoErogante(AziendaErogante, NumeroNosologico) AS RepartoErogante
			,IdPaziente
			,CONVERT(VARCHAR(16), dbo.GetEventiAttributo(dbo.GetEventiIdEventoAccettazione(AziendaErogante, NumeroNosologico), 'OspedaleCodice')) AS OspedaleCodice
			--,NUOVA FUNZIONE . bisogna mettersi d'accordo sul nome dell'attributo OspedaleDescrizione
			,CONVERT(VARCHAR(128),
					dbo.GetRicoveroOspedaleDesc(
							CONVERT(VARCHAR(16) ,dbo.GetEventiAttributo(dbo.GetEventiIdEventoAccettazione(AziendaErogante, NumeroNosologico), 'OspedaleCodice'     )),
							CONVERT(VARCHAR(128),dbo.GetEventiAttributo(dbo.GetEventiIdEventoAccettazione(AziendaErogante, NumeroNosologico), 'OspedaleDescrizione'))
					) 
			)AS OspedaleDescr

			,dbo.GetRicoveroTipoRicoveroCodice(AziendaErogante, NumeroNosologico) AS TipoRicoveroCodice
			,dbo.GetEventiTipoEpisodioDesc(
								NULL 
								,dbo.GetRicoveroTipoRicoveroCodice(AziendaErogante, NumeroNosologico)
								,CONVERT(VARCHAR(128), 
								dbo.GetEventiAttributo( 
											dbo.GetEventiIdEventoAccettazione(AziendaErogante, NumeroNosologico)
											,'TipoEpisodioDescr')
								)
			) AS TipoRicoveroDescr

			,dbo.GetRicoveroDiagnosi(AziendaErogante, NumeroNosologico) AS Diagnosi
			,dbo.GetRicoveroDataAccettazione(AziendaErogante, NumeroNosologico) AS DataAccettazione
				
			,dbo.GetRicoveroRepartoAccettazioneCodice(AziendaErogante, NumeroNosologico) AS RepartoAccettazioneCodice
			,dbo.GetRicoveroRepartoAccettazioneDesc(AziendaErogante, NumeroNosologico) AS RepartoAccettazioneDescr

			,dbo.GetRicoveroDataTrasferimento(AziendaErogante, NumeroNosologico) AS DataTrasferimento
			,dbo.GetRicoveroRepartoCodice(AziendaErogante, NumeroNosologico) AS RepartoCodice
			,dbo.GetRicoveroRepartoDesc(AziendaErogante, NumeroNosologico) AS RepartoDescr
			,dbo.GetRicoveroSettoreCodice(AziendaErogante, NumeroNosologico) AS SettoreCodice
			,dbo.GetRicoveroSettoreDesc(AziendaErogante, NumeroNosologico) AS SettoreDescr
			,dbo.GetRicoveroLettoCodice(AziendaErogante, NumeroNosologico) AS LettoCodice
			
			,dbo.GetRicoveroDataDimissione(AziendaErogante, NumeroNosologico) AS DataDimissione

		FROM 
			store.EventiBase
		WHERE
			AziendaErogante = @AziendaERogante
			AND NumeroNosologico = @NumeroNosologico

		IF @@ERROR <> 0 GOTO ERROR_EXIT

	END 
	--
	--
	--
	RETURN 0

ERROR_EXIT:
	RETURN 1

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiRicoveroConsolidaRicovero2] TO [ExecuteExt]
    AS [dbo];

