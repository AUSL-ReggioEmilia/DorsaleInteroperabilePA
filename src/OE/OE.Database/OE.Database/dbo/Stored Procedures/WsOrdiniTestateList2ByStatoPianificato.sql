
-- =============================================
-- Author:		Alessandro Nostini
-- Created date: 2020-03-09
-- Modify date: 2020-04-09 Uso Exists con la tabella RicercaOrdini. deve tornare solo 1 record
-- Modify date: 2020-05-14 Modificato parametro UnitaOperativa ora è una lista (stringa con guid csv)
-- Modify date: 2020-06-10 Mancava il filtro per paziente e nosologico
-- Modify date: 2020-06-23 Filtro solo per DataPianificazione (Erogante) oppure DataPrenotazione (Erogante)
--
-- Description:	Seleziona una lista di testate ordine con controllo ennuple di accesso ai sistemi
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateList2ByStatoPianificato]
(
 @Utente VARCHAR(64)
,@MaxRecord INT
,@DataPianificataInizio DATETIME2(0)
,@DataPianificataFine DATETIME2(0)
,@IdSac UNIQUEIDENTIFIER = NULL
,@IdSistemaErogante UNIQUEIDENTIFIER = NULL
,@ListIdUnitaOperativa VARCHAR(MAX) = NULL
,@Nosologico VARCHAR(64) = NULL
,@Cognome VARCHAR(64) = NULL
,@Nome VARCHAR(64) = NULL
,@DataNascita DATE = NULL
,@AnnoNascita INT = NULL
)
AS
BEGIN
------------------------------------------
--Aggiungere campi a vista:
--
--DataPrenotazioneRichiesta
--DataPrenotazioneErogante
--DataPianificazioneErogante
--DataModificaPianificazione
--
------------------------------------------
--Filtri cablati:

--Stati: dall’inoltrato in avanti (esclusi gli erogati, esclusi i bozza) --> rimangono gli ACCETTATI, IN CARICO e PROGRAMMATI
--
------------------------------------------
--Parametri:
--
--Range di Data Pianificata dall’erogante (Data Dal, Data Al) --> interessa solo quanto pianificato per il futuro?
--IdSac: opzionale
--Sistema e Azienda Erogante: opzionale
--Reparto Richiedente: opzionale
--Nosologico: opzionale
--Cognome: opzionale
--Nome: opzionale
--Data di nascita: opzionale
--Anno di Nascita: opzionale
--

	SET NOCOUNT ON;

	--Se manca TOP setto il default
	IF @MaxRecord = 0 OR @MaxRecord IS NULL
		SET @MaxRecord = 100

	-- Tabella temporanea contenente le ennuple di accesso ai sistemi
	DECLARE @A TABLE (IDSistemaErogante uniqueidentifier, [R] bit NOT NULL, [I] bit NOT NULL, [S] bit NOT NULL, [Not] bit NOT NULL)
	INSERT INTO @A 
		SELECT * FROM dbo.GetEnnupleAccessi(@Utente, 1)

	-- Split unità operative
	--
	DECLARE @UO TABLE ([Id] uniqueidentifier)
	INSERT INTO @UO
		SELECT [Value] FROM [dbo].[SplitStringToListGiud](@ListIdUnitaOperativa)

	DECLARE @UoCount INT = (SELECT COUNT(*) FROM @UO)

	-- Cerco gli ordini
	--
	SELECT TOP(@MaxRecord) *
	FROM (
			--Query risultato
			--
			SELECT 
				ID, DataInserimento, DataModifica, Anno, Numero
				, IDUnitaOperativaRichiedente, CodiceUnitaOperativaRichiedente, DescrizioneUnitaOperativaRichiedente
				, CodiceAziendaUnitaOperativaRichiedente, DescrizioneAziendaUnitaOperativaRichiedente
				, IDSistemaRichiedente, CodiceSistemaRichiedente, DescrizioneSistemaRichiedente
				, CodiceAziendaSistemaRichiedente, DescrizioneAziendaSistemaRichiedente
				, NumeroNosologico, IDRichiestaRichiedente, DataRichiesta, StatoOrderEntry, SottoStatoOrderEntry
				, StatoRisposta, DataModificaStato, StatoRichiedente, Data, Operatore
				, PrioritaCodice, PrioritaDescrizione, TipoEpisodio, AnagraficaCodice, AnagraficaNome
				, PazienteIdRichiedente, PazienteIdSac, PazienteRegime, PazienteCognome, PazienteNome
				, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale, Paziente, Consensi, Note
				, RegimeCodice, RegimeDescrizione, DataPrenotazione, StatoValidazione, Validazione
				, StatoTransazione, DataTransazione, DescrizioneStato, SistemiEroganti, TotaleRighe
				, AnteprimaPrestazioni, Cancellabile, DataPrenotazioneRichiesta
				, DataPrenotazioneErogante, DataPianificazioneErogante

				--Per l'ordinamento uso la query locale
				, RO.DataModificaPianificazione

			FROM dbo.WsOrdiniTestateList2 TL
				INNER JOIN (
						--
						-- Uso EXISTS per non raddoppiare i record di output
						--
						SELECT DISTINCT IdOrdineTestata, DataModificaPianificazione 
						FROM [dbo].[RicercaOrdini] FO WITH(NOLOCK)
						WHERE FO.OrderEntryStato IN ('AA', 'SE', 'IC', 'IP')
							--
							-- Filtro per data DataPianificazioneErogante ma se NULL, DataPrenotazioneErogante
							--
							AND (
									(FO.DataPianificazioneErogante >= @DataPianificataInizio AND FO.DataPianificazioneErogante <= @DataPianificataFine
										AND NOT FO.DataPianificazioneErogante IS NULL)

								OR	(FO.DataPrenotazioneErogante >= @DataPianificataInizio	AND FO.DataPrenotazioneErogante <= @DataPianificataFine
										AND FO.DataPianificazioneErogante IS NULL)
								)

							AND (FO.IdSistemaErogante = @IdSistemaErogante OR @IdSistemaErogante IS NULL)
							AND (EXISTS(SELECT * FROM @UO uo WHERE uo.Id = FO.IdUnitaOperativa)	OR @UoCount = 0)
					) RO
				ON RO.IdOrdineTestata = TL.ID

			WHERE (TL.PazienteIdSac = @IdSac OR @IdSac IS NULL)
				AND (TL.NumeroNosologico = @Nosologico OR @Nosologico IS NULL)

				AND (TL.PazienteCognome LIKE @Cognome + '%' OR @Cognome IS NULL)
				AND (TL.PazienteNome LIKE @Nome + '%' OR @Nome IS NULL)
				AND (TL.PazienteDataNascita = @DataNascita OR @DataNascita IS NULL)
				AND (YEAR(TL.PazienteDataNascita) = @AnnoNascita OR NULLIF(@AnnoNascita, 0) IS NULL)
		) T

	WHERE (
		 	-- Abilitazione totale ai sistema
			EXISTS (SELECT * FROM @A A
							WHERE A.IDSistemaErogante IS NULL
								AND A.[Not] = 0 AND A.[R] = 1)
			OR
			-- Include sistema
			EXISTS( SELECT * FROM [dbo].[GetGerarchiaPrestazioniOrdineByIdTestata](T.ID) G
								INNER JOIN dbo.Prestazioni P WITH(NOLOCK)
									ON P.ID = G.IDFiglio
									AND P.Tipo = 0
								INNER JOIN @A A
									ON P.IdSistemaErogante = A.IdSistemaErogante
									AND A.[Not] = 0 AND A.[R] = 1)
			OR
			-- Nessuna riga
			NOT EXISTS (SELECT * FROM dbo.OrdiniRigheRichieste ORR WITH(NOLOCK)
							WHERE ORR.IDOrdineTestata = T.ID)
			)
		AND 
		 	-- Esclude totale ai sistema
			NOT EXISTS (SELECT * FROM @A A
							WHERE A.IDSistemaErogante IS NULL
								AND A.[Not] = 1 AND A.[R] = 1)
		AND
			--Esclude sistemi in NOT
			NOT EXISTS( SELECT * FROM [dbo].[GetGerarchiaPrestazioniOrdineByIdTestata](T.ID) G
								INNER JOIN dbo.Prestazioni P WITH(NOLOCK)
									ON P.ID = G.IDFiglio
									AND P.Tipo = 0
								INNER JOIN @A A
									ON P.IdSistemaErogante = A.IdSistemaErogante
									AND A.[Not] = 1 AND A.[R] = 1)

	ORDER BY DataModificaPianificazione DESC
	OPTION (RECOMPILE)
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateList2ByStatoPianificato] TO [DataAccessWs]
    AS [dbo];

