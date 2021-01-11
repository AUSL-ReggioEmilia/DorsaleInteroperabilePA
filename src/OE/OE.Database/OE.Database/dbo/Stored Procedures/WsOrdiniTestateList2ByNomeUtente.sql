
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-25 SANDRO: Aggiunto filtro per @IdSistemaErogante
-- Modify date: 2014-10-27 SANDRO: Copiata da [WsOrdiniTestateListByUnitaOperative]
--									Onora le ennuple di accesso ai sistemi (nuovo paramente @utente)
--									Ritorna per i Sistemi eroganti la descrizione
-- Modify date: 2012-10-30 - Uso [GetGerarchiaPrestazioniOrdineByIdTestata]() per cercare le prestazioni
--									Aggiunta SubQuery per le performance
--
-- Description:	Seleziona una lista di testate ordine filtrate per utente di modifica o inserimento
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateList2ByNomeUtente]
@Utente VARCHAR (64), @NomeUtente VARCHAR (64), @NumeroNosologico VARCHAR (64), @PazienteCognome VARCHAR (64), @PazienteNome VARCHAR (64), @PazienteDataNascita DATE, @Stati VARCHAR (MAX), @DataRichiestaInizio DATETIME2 (0), @DataRichiestaFine DATETIME2 (0)
WITH RECOMPILE
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

	-- Split stati
	DECLARE @Value varchar(50), @Pos int
	DECLARE @tmp TABLE (StatoDesc varchar(max))

	SET @Stati = LTRIM(RTRIM(@Stati))+ ','
	SET @Pos = CHARINDEX(',', @Stati, 1)

	IF REPLACE(@Stati, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @Value = LTRIM(RTRIM(LEFT(@Stati, @Pos - 1)))
			
			IF @Value <> ''
			BEGIN
				INSERT INTO @tmp (StatoDesc) VALUES (@Value)
			END
			
			SET @Stati = RIGHT(@Stati, LEN(@Stati) - @Pos)
			SET @Pos = CHARINDEX(',', @Stati, 1)
		END
	END

	SELECT *
	FROM (  --Query risultato
			SELECT TOP(@MaxRecord) T.*
			FROM dbo.WsOrdiniTestateList2 T
					INNER JOIN OrdiniTestate OT WITH(NOLOCK) ON OT.ID = T.ID
					INNER JOIN Tickets TKI WITH(NOLOCK) ON OT.IDTicketInserimento = TKI.ID
					INNER JOIN Tickets TKM WITH(NOLOCK) ON OT.IDTicketModifica = TKM.ID
					
			WHERE (TKI.UserName = @NomeUtente OR TKM.UserName = @NomeUtente)
				AND (@NumeroNosologico IS NULL OR T.NumeroNosologico = @NumeroNosologico)
				AND (@PazienteCognome IS NULL OR T.PazienteCognome LIKE '%' + @PazienteCognome + '%')
				AND (@PazienteNome IS NULL OR T.PazienteNome LIKE '%' + @PazienteNome + '%')
				AND (@PazienteDataNascita IS NULL OR T.PazienteDataNascita = @PazienteDataNascita)
				AND (T.DescrizioneStato IN ( SELECT StatoDesc FROM @tmp) OR  @Stati IS NULL)
				AND T.DataRichiesta >= @DataRichiestaInizio
				AND T.DataRichiesta <= @DataRichiestaFine
			) T1

		WHERE (
		 	-- Abilitazione totale ai sistema
			EXISTS (SELECT * FROM @A A
							WHERE A.IDSistemaErogante IS NULL
								AND A.[Not] = 0 AND A.[R] = 1)
			OR
			-- Include sistema
			EXISTS( SELECT * FROM [dbo].[GetGerarchiaPrestazioniOrdineByIdTestata](T1.ID) G
								INNER JOIN dbo.Prestazioni P WITH(NOLOCK)
									ON P.ID = G.IDFiglio
									AND P.Tipo = 0
								INNER JOIN @A A
									ON P.IdSistemaErogante = A.IdSistemaErogante
									AND A.[Not] = 0 AND A.[R] = 1)
			OR
			-- Nessuna riga
			NOT EXISTS (SELECT * FROM dbo.OrdiniRigheRichieste ORR WITH(NOLOCK)
							WHERE ORR.IDOrdineTestata = T1.ID)
			)
		AND 
		 	-- Esclude totale ai sistema
			NOT EXISTS (SELECT * FROM @A A
							WHERE A.IDSistemaErogante IS NULL
								AND A.[Not] = 1 AND A.[R] = 1)
		AND
			--Esclude sistemi in NOT
			NOT EXISTS( SELECT * FROM [dbo].[GetGerarchiaPrestazioniOrdineByIdTestata](T1.ID) G
								INNER JOIN dbo.Prestazioni P WITH(NOLOCK)
									ON P.ID = G.IDFiglio
									AND P.Tipo = 0
								INNER JOIN @A A
									ON P.IdSistemaErogante = A.IdSistemaErogante
									AND A.[Not] = 1 AND A.[R] = 1)			
	ORDER BY T1.DataRichiesta
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateList2ByNomeUtente] TO [DataAccessWs]
    AS [dbo];

