
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-10-27 - Copiata da WsOrdiniTestateListByDataModifica2
-- Modify date: 2012-10-27 - Aggiunto test di accesso ai sistemi
-- Modify date: 2012-10-30 - Uso [GetGerarchiaPrestazioniOrdineByIdTestata]() per cercare le prestazioni
--
-- Description:	Seleziona una lista di testate ordine e onora accessi ai sistemi eroganti
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateList2ByDataModifica]
	  @Utente varchar(64)
	, @DataModificaInizio datetime2(0)
	, @DataModificaFine datetime2(0)
AS
BEGIN
	SET NOCOUNT ON;

	--Se filtro scarso abbasso il TOP
	DECLARE @MaxRecord INT = 1000
	IF @DataModificaInizio IS NULL OR @DataModificaFine IS NULL OR DATEDIFF(day, @DataModificaInizio, @DataModificaFine) > 90
		SET @MaxRecord = 500

	-- Tabella temporanea contenente le ennuple di accesso ai sistemi
	DECLARE @A TABLE (IDSistemaErogante uniqueidentifier, [R] bit NOT NULL, [I] bit NOT NULL, [S] bit NOT NULL, [Not] bit NOT NULL)
	INSERT INTO @A 
		SELECT * FROM dbo.GetEnnupleAccessi(@Utente, 1)

	--Query delle richieste
	SELECT TOP(@MaxRecord) T.*
	FROM dbo.WsOrdiniTestateList2 T
	WHERE T.DataModifica >= @DataModificaInizio
		 AND T.DataModifica <= @DataModificaFine

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
	ORDER BY T.DataModifica DESC
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateList2ByDataModifica] TO [DataAccessWs]
    AS [dbo];

