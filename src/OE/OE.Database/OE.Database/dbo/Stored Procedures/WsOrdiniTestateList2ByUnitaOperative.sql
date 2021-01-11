-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-25 SANDRO: Aggiunto filtro per @IdSistemaErogante
-- Modify date: 2014-10-27 SANDRO: Copiata da [WsOrdiniTestateListByUnitaOperative]
--									Onora le ennuple di accesso ai sistemi (nuovo paramente @utente)
--									Ritorna per i Sistemi eroganti la descrizione
-- Modify date: 2012-10-30 - Uso [GetGerarchiaPrestazioniOrdineByIdTestata]() per cercare le prestazioni
-- Modify date: 2016-10-06 - Aggiunto OPTION (RECOMPILE) per SQL 2014
-- Modify date: 2016-10-13 - Modificato filtro UO da JOIN a WHERE EXISTS
--
-- Description:	Seleziona una lista di testate ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateList2ByUnitaOperative]
(
  @Utente VARCHAR (64)
, @IDsUnitaOperativeRichiedente VARCHAR (MAX)
, @NumeroNosologico VARCHAR (64)
, @PazienteCognome VARCHAR (64)
, @PazienteNome VARCHAR (64)
, @PazienteDataNascita DATE
, @Stati VARCHAR (MAX)
, @DataRichiestaInizio DATETIME2(0)
, @DataRichiestaFine DATETIME2(0)
, @IdSistemaErogante UNIQUEIDENTIFIER
)
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

	-- Split unità operative
	DECLARE @ValueUO varchar(50), @PosUO int
	DECLARE @tmpUnitaOperative TABLE (ID uniqueidentifier)

	SET @IDsUnitaOperativeRichiedente = LTRIM(RTRIM(@IDsUnitaOperativeRichiedente))+ ','
	SET @PosUO = CHARINDEX(',', @IDsUnitaOperativeRichiedente, 1)

	IF REPLACE(@IDsUnitaOperativeRichiedente, ',', '') <> ''
	BEGIN
		WHILE @PosUO > 0
		BEGIN
			SET @ValueUO = LTRIM(RTRIM(LEFT(@IDsUnitaOperativeRichiedente, @PosUO - 1)))
			
			IF @ValueUO <> ''
			BEGIN
				INSERT INTO @tmpUnitaOperative (ID) VALUES (@ValueUO)
			END
			
			SET @IDsUnitaOperativeRichiedente = RIGHT(@IDsUnitaOperativeRichiedente, LEN(@IDsUnitaOperativeRichiedente) - @PosUO)
			SET @PosUO = CHARINDEX(',', @IDsUnitaOperativeRichiedente, 1)
		END
	END
			
	-- Split stati
	DECLARE @ValueStati varchar(50), @PosStati int
	DECLARE @tmpStati TABLE (DescrizioneStato varchar(max))

	SET @Stati = LTRIM(RTRIM(@Stati))+ ','
	SET @PosStati = CHARINDEX(',', @Stati, 1)

	IF REPLACE(@Stati, ',', '') <> ''
	BEGIN
		WHILE @PosStati > 0
		BEGIN
			SET @ValueStati = LTRIM(RTRIM(LEFT(@Stati, @PosStati - 1)))
			
			IF @ValueStati <> ''
			BEGIN
				INSERT INTO @tmpStati (DescrizioneStato) VALUES (@ValueStati)
			END
			
			SET @Stati = RIGHT(@Stati, LEN(@Stati) - @PosStati)
			SET @PosStati = CHARINDEX(',', @Stati, 1)
		END
	END
		
	--Query risultato
	SELECT TOP(@MaxRecord) T.*
	FROM dbo.WsOrdiniTestateList2 T

	-- SQL 2014 Uso EXISTS invece della JOIN 
	WHERE EXISTS (SELECT * FROM @tmpUnitaOperative TmpUO
					WHERE TmpUO.ID = T.IDUnitaOperativaRichiedente)

		AND T.DataRichiesta >= @DataRichiestaInizio
		AND T.DataRichiesta <= @DataRichiestaFine 
						
		AND (@NumeroNosologico IS NULL OR T.NumeroNosologico = @NumeroNosologico)
		AND (@PazienteCognome IS NULL OR T.PazienteCognome LIKE '%' + @PazienteCognome + '%')
		AND (@PazienteNome IS NULL OR T.PazienteNome LIKE '%' + @PazienteNome + '%')
		AND (@PazienteDataNascita IS NULL OR T.PazienteDataNascita = @PazienteDataNascita)
		
		AND (@Stati IS NULL OR EXISTS (SELECT * FROM @tmpStati stati 
										WHERE stati.DescrizioneStato = T.DescrizioneStato)
			)

		AND (@IdSistemaErogante IS NULL OR EXISTS (SELECT * FROM dbo.OrdiniRigheRichieste orr
													WHERE orr.IDOrdineTestata = T.ID
														AND orr.IDSistemaErogante = @IdSistemaErogante)
			)

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
	-- Per SQL 2014
	OPTION (RECOMPILE)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateList2ByUnitaOperative] TO [DataAccessWs]
    AS [dbo];

