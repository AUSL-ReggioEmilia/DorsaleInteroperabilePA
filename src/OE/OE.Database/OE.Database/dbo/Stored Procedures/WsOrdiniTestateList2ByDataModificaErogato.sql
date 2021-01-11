
CREATE PROCEDURE [dbo].[WsOrdiniTestateList2ByDataModificaErogato]
@Utente VARCHAR (64), @MaxRecord INT, @DataModificaInizio DATETIME2 (0), @DataModificaFine DATETIME2 (0), @IDSistemaRichiedente UNIQUEIDENTIFIER, @IDSistemaErogante UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	--Se manca TOP setto il default
	IF @MaxRecord = 0 OR @MaxRecord IS NULL
		SET @MaxRecord = 5000

	-- Tabella temporanea contenente le ennuple di accesso ai sistemi
	DECLARE @A TABLE (IDSistemaErogante uniqueidentifier, [R] bit NOT NULL, [I] bit NOT NULL, [S] bit NOT NULL, [Not] bit NOT NULL)
	INSERT INTO @A 
		SELECT * FROM dbo.GetEnnupleAccessi(@Utente, 1)

	--Query delle richieste
	SELECT T_RET.ID, DataInserimento, OTEM.DataModifica, Anno, Numero
		, IDUnitaOperativaRichiedente, CodiceUnitaOperativaRichiedente, DescrizioneUnitaOperativaRichiedente
		, CodiceAziendaUnitaOperativaRichiedente, DescrizioneAziendaUnitaOperativaRichiedente
		, IDSistemaRichiedente, CodiceSistemaRichiedente, DescrizioneSistemaRichiedente
		, CodiceAziendaSistemaRichiedente, DescrizioneAziendaSistemaRichiedente
		, NumeroNosologico, IDRichiestaRichiedente, DataRichiesta
		, StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta
		, DataModificaStato, StatoRichiedente, Data, Operatore
		, PrioritaCodice, PrioritaDescrizione, TipoEpisodio
		, AnagraficaCodice, AnagraficaNome, PazienteIdRichiedente, PazienteIdSac, PazienteRegime, PazienteCognome, PazienteNome
		, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale, Paziente, Consensi, Note
		, RegimeCodice, RegimeDescrizione, DataPrenotazione, StatoValidazione, Validazione, StatoTransazione
		, DataTransazione, DescrizioneStato, SistemiEroganti, TotaleRighe, AnteprimaPrestazioni, Cancellabile
	
	FROM dbo.WsOrdiniTestateList2 T_RET
		INNER JOIN (
			--
			-- Lista ID modificati
			SELECT TOP(@MaxRecord) OT.ID
					, MAX(OET.DataModifica) DataModifica
			FROM dbo.OrdiniTestate OT WITH(READPAST)
			
				INNER JOIN dbo.OrdiniRigheRichieste ORR WITH(READPAST)
					ON ORR.IDOrdineTestata = OT.ID

				INNER JOIN dbo.OrdiniErogatiTestate OET WITH(READPAST)
					ON OT.ID = OET.IDOrdineTestata

				--INNER JOIN dbo.OrdiniRigheErogate ORE WITH(READPAST)
				--	ON OET.ID = ORE.IDOrdineErogatoTestata

			--WHERE ORE.DataModifica >= @DataModificaInizio
			--	 AND (@DataModificaFine IS NULL OR ORE.DataModifica <= @DataModificaFine)
	
			  WHERE OET.DataModifica >= @DataModificaInizio
				 AND (@DataModificaFine IS NULL OR OET.DataModifica <= @DataModificaFine)
	 
				 AND (@IDSistemaRichiedente IS NULL OR OT.IDSistemaRichiedente = @IDSistemaRichiedente)

				 --AND (@IDSistemaErogante IS NULL OR EXISTS (SELECT * FROM dbo.OrdiniRigheRichieste ORR WITH(NOLOCK)
					--										WHERE ORR.IDOrdineTestata = OT.ID
					--											AND ORR.IDSistemaErogante = @IDSistemaErogante)
					--								)

				 AND (@IDSistemaErogante IS NULL OR ORR.IDSistemaErogante = @IDSistemaErogante)

				 AND (
		 			-- Abilitazione totale ai sistema
					EXISTS (SELECT * FROM @A A
									WHERE A.IDSistemaErogante IS NULL
										AND A.[Not] = 0 AND A.[R] = 1)
					OR
					-- Include sistema
					EXISTS( SELECT * FROM [dbo].[GetGerarchiaPrestazioniOrdineByIdTestata](OT.ID) G
										INNER JOIN dbo.Prestazioni P WITH(NOLOCK)
											ON P.ID = G.IDFiglio
											AND P.Tipo = 0
										INNER JOIN @A A
											ON P.IdSistemaErogante = A.IdSistemaErogante
											AND A.[Not] = 0 AND A.[R] = 1)
					OR
					-- Nessuna riga
					NOT EXISTS (SELECT * FROM dbo.OrdiniRigheRichieste ORR WITH(NOLOCK)
									WHERE ORR.IDOrdineTestata = OT.ID)
					)
				AND 
		 			-- Esclude totale ai sistema
					NOT EXISTS (SELECT * FROM @A A
									WHERE A.IDSistemaErogante IS NULL
										AND A.[Not] = 1 AND A.[R] = 1)
				AND
					--Esclude sistemi in NOT
					NOT EXISTS( SELECT * FROM [dbo].[GetGerarchiaPrestazioniOrdineByIdTestata](OT.ID) G
										INNER JOIN dbo.Prestazioni P WITH(NOLOCK)
											ON P.ID = G.IDFiglio
											AND P.Tipo = 0
										INNER JOIN @A A
											ON P.IdSistemaErogante = A.IdSistemaErogante
											AND A.[Not] = 1 AND A.[R] = 1)
			GROUP BY OT.[ID]
			) OTEM

		ON T_RET.ID = OTEM.ID

	ORDER BY OTEM.DataModifica DESC

END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateList2ByDataModificaErogato] TO [DataAccessWs]
    AS [dbo];

