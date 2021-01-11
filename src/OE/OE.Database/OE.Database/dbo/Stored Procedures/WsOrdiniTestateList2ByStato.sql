
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-03-01
-- Modify date: 2013-11-21 SANDRO: DataPrenotazione
-- Modify date: 2014-02-14 SANDRO: Nuova versione tolti: T.IDTicketInserimento T.IDTicketModifica
--									Usa vista comune le SP dello stesso TableAdapter
-- Create date: 2012-10-27 - Copiata da WsOrdiniTestateListByDataModifica2
-- Modify date: 2012-10-27 - Aggiunto test di accesso ai sistemi
-- Modify date: 2012-10-30 - Uso [GetGerarchiaPrestazioniOrdineByIdTestata]() per cercare le prestazioni
--
-- Description:	Seleziona una lista di testate ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateList2ByStato]
(	  @Utente varchar(64)
	, @Stato varchar(64)
	, @NumeroNosologico varchar(64)
	, @PazienteCognome varchar(64)
	, @PazienteNome varchar(64)
	, @PazienteDataNascita date
	, @IDSistemaRichiedente uniqueidentifier
	, @DataRichiestaInizio datetime2(0)
	, @DataRichiestaFine datetime2(0)
) WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	IF @Stato IS NULL
		SET @Stato = 'Erogato'
	
	IF NOT (@Stato = 'Erogato' OR @Stato = 'Errato')
		RAISERROR('Il parametro @Stato non è valdo! Valori possibili: Erogato, Errato', 16, 1)

	--Se filtro scarso abbasso il TOP
	DECLARE @MaxRecord INT = 1000
	IF @DataRichiestaInizio IS NULL OR @DataRichiestaFine IS NULL OR DATEDIFF(day, @DataRichiestaInizio, @DataRichiestaFine) > 90
		SET @MaxRecord = 500

	-- Tabella temporanea contenente le ennuple di accesso ai sistemi
	DECLARE @A TABLE (IDSistemaErogante uniqueidentifier, [R] bit NOT NULL, [I] bit NOT NULL, [S] bit NOT NULL, [Not] bit NOT NULL)
	INSERT INTO @A 
		SELECT * FROM dbo.GetEnnupleAccessi(@Utente, 1)

	--Query delle richieste
	SELECT TOP(@MaxRecord) T.*
	FROM dbo.WsOrdiniTestateList2 T
	WHERE ((@NumeroNosologico IS NULL) OR (T.NumeroNosologico = @NumeroNosologico))
		AND ((@PazienteCognome IS NULL) OR (T.PazienteCognome LIKE '%' + @PazienteCognome + '%'))
		AND ((@PazienteNome IS NULL) OR (T.PazienteNome LIKE '%' + @PazienteNome + '%'))
		AND ((@PazienteDataNascita IS NULL) OR (T.PazienteDataNascita = @PazienteDataNascita))		
		AND ((@IDSistemaRichiedente IS NULL) OR (T.IDSistemaRichiedente = @IDSistemaRichiedente))		
					
		AND T.DataRichiesta >= @DataRichiestaInizio
		AND T.DataRichiesta <= @DataRichiestaFine
		AND T.DescrizioneStato = @Stato

		AND (
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
	ORDER BY T.DataRichiesta
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateList2ByStato] TO [DataAccessWs]
    AS [dbo];

