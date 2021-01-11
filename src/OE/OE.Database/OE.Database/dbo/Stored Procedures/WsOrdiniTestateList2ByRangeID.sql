
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2012-03-01
-- Modify date: 2013-11-21 SANDRO: DataPrenotazione
-- Modify date: 2014-02-14 SANDRO: Nuova versione tolti: T.IDTicketInserimento T.IDTicketModifica
--									Usa vista comune le SP dello stesso TableAdapter
-- Modify date: 2014-10-27 SANDRO: Copiata da [WsOrdiniTestateListByRangeID2]
--									Onora le ennuple di accesso ai sistemi (nuovo paramente @utente)
--									Ritorna per i Sistemi eroganti la descrizione
-- Modify date: 2012-10-30 - Uso [GetGerarchiaPrestazioniOrdineByIdTestata]() per cercare le prestazioni
--
-- Description:	Seleziona una lista di testate ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateList2ByRangeID]
	  @Utente as varchar(64)
	, @ids AnnoNumero READONLY
AS
BEGIN
	SET NOCOUNT ON;

	-- Tabella temporanea contenente le ennuple di accesso ai sistemi
	DECLARE @A TABLE (IDSistemaErogante uniqueidentifier, [R] bit NOT NULL, [I] bit NOT NULL, [S] bit NOT NULL, [Not] bit NOT NULL)
	INSERT INTO @A 
		SELECT * FROM dbo.GetEnnupleAccessi(@Utente, 1)

	SELECT T.*
	FROM dbo.WsOrdiniTestateList2 T
		INNER JOIN @ids ids ON (T.Anno = ids.Anno AND T.Numero = ids.Numero)

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
	ORDER BY T.DataRichiesta
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateList2ByRangeID] TO [DataAccessWs]
    AS [dbo];

