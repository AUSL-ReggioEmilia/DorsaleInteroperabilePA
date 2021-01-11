
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2012-03-01
-- Modify date: 2013-11-21 SANDRO: DataPrenotazione
-- Modify date: 2014-02-14 SANDRO: Nuova versione tolti: T.IDTicketInserimento T.IDTicketModifica
--									Usa vista comune le SP dello stesso TableAdapter
-- Modify date: 2014-10-27 SANDRO: Copiata da [WsOrdiniTestateListByNosologico5]
--									Onora le ennuple di accesso ai sistemi (nuovo paramente @utente)
--									Ritorna per i Sistemi eroganti la descrizione
-- Modify date: 2012-10-30 - Uso [GetGerarchiaPrestazioniOrdineByIdTestata]() per cercare le prestazioni
--
-- Description:	Seleziona una lista di testate ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateList2ByNosologico]
	  @Utente as varchar(64)
	, @NumeroNosologico varchar(64)
	, @DataRichiestaInizio datetime2(0)
	, @DataRichiestaFine datetime2(0)
AS
BEGIN
	SET NOCOUNT ON;

	--Se filtro scarso abbasso il TOP
	DECLARE @MaxRecord INT = 1000
	IF @DataRichiestaInizio IS NULL OR @DataRichiestaFine IS NULL OR DATEDIFF(day, @DataRichiestaInizio, @DataRichiestaFine) > 90
		SET @MaxRecord = 500

	-- Tabella temporanea contenente le ennuple di accesso ai sistemi
	DECLARE @A TABLE (IDSistemaErogante uniqueidentifier, [R] bit NOT NULL, [I] bit NOT NULL, [S] bit NOT NULL, [Not] bit NOT NULL)
	INSERT INTO @A 
		SELECT * FROM dbo.GetEnnupleAccessi(@Utente, 1)

	--Query risultato
	SELECT TOP(@MaxRecord) T.*
	FROM dbo.WsOrdiniTestateList2 T
	WHERE T.NumeroNosologico = @NumeroNosologico
		AND T.DataRichiesta >= @DataRichiestaInizio
		AND T.DataRichiesta <= @DataRichiestaFine

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
    ON OBJECT::[dbo].[WsOrdiniTestateList2ByNosologico] TO [DataAccessWs]
    AS [dbo];

