
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2016-05-03 - Usa SistemiEstesa per limitare le Query Distribuite
-- Modify date: 2016-10-05 - Filtra anche per P.Tipo per ottimizzare il CROSS APPLY delle gerarchie
-- Modify date: 2016-10-06 - Usa OUTER APPLY delle gerarchie perchè filtra anche per P.Tipo
-- Modify date:  2018-02-07 SANDRO: Aggiunto OPTION (RECOMPILE)
--
-- Description:	Lista dell eprestazioni dei gruppi preferiti
--
-- =============================================
CREATE FUNCTION [dbo].[GetGruppiPrestazioniPreferiti]
(
  @Utente VARCHAR (64)
, @idUnitaOperativa UNIQUEIDENTIFIER
, @idSistemaRichiedente UNIQUEIDENTIFIER
, @codiceRegime VARCHAR (16)
, @codicePriorita VARCHAR (16)
, @idStato TINYINT
, @FiltroDescrizione VARCHAR (256)
)
RETURNS 
    @Result TABLE (
        [ID]                UNIQUEIDENTIFIER NOT NULL,
        [Descrizione]       VARCHAR (256)    NULL,
        [IdSistemaErogante] UNIQUEIDENTIFIER NOT NULL,
        [NumeroPrestazioni] INT              NOT NULL)
AS
BEGIN
	-- Controllo parametri
	SET @FiltroDescrizione = NULLIF(@FiltroDescrizione, '')
	SET @idStato = ISNULL(@idStato, 1)

	-- Tabella temporanea contenente le ennuple delle prestazioni
	DECLARE @T TABLE (IdGruppoPrestazioni uniqueidentifier, [Not] bit NOT NULL) 
	INSERT INTO @T 
		SELECT * FROM dbo.GetEnnuple(@utente, @idUnitaOperativa, @idSistemaRichiedente, NULL, @codiceRegime, @codicePriorita, @idStato)

	-- Tabella temporanea contenente le ennuple di accesso ai sistemi
	DECLARE @A TABLE (IDSistemaErogante uniqueidentifier, [R] bit NOT NULL, [I] bit NOT NULL, [S] bit NOT NULL, [Not] bit NOT NULL)
	INSERT INTO @A 
		SELECT * FROM dbo.GetEnnupleAccessi(@utente, @idStato)
		
	-- Gruppi preferiti con accesso
	INSERT INTO @Result
	SELECT GRUPPI.[Id]
			, GRUPPI.[Descrizione]
			, GRUPPI.IdSistemaErogante
			, COUNT(IDPrestazione)
	FROM (
			SELECT *
			FROM (
					-- Gruppi con profili
					SELECT GP.[Id]
						, GP.[Descrizione]
						, GER.IDFiglio AS IDPrestazione
						, GER.IdSistemaErogante

					FROM dbo.[GruppiPrestazioni] GP
						INNER JOIN dbo.[PrestazioniGruppiPrestazioni] PGP
							ON GP.ID = PGP.IDGruppoPrestazioni

						-- NUOVO su SQL 2014
						INNER JOIN dbo.[Prestazioni] P
							ON P.ID = PGP.IDPrestazione
						OUTER APPLY [dbo].[GetProfiloGerarchia2](P.ID) GER

					WHERE P.Tipo <> 0
						AND GP.Preferiti = 1
						AND GER.Attivo = 1

					UNION
					-- Gruppi con prestazioni
					SELECT GP.[Id]
						, GP.[Descrizione]
						, PGP.IDPrestazione
						, P.IDSistemaErogante

					FROM dbo.[GruppiPrestazioni] GP
						INNER JOIN dbo.[PrestazioniGruppiPrestazioni] PGP
							ON GP.ID = PGP.IDGruppoPrestazioni
						INNER JOIN dbo.[Prestazioni] P
							ON P.ID = PGP.IDPrestazione
					WHERE P.Tipo = 0
						AND GP.Preferiti = 1
						AND P.Attivo = 1
				) G
				
			WHERE 
				-- Filtro per Codice e Sistema Erogante
				  (@FiltroDescrizione IS NULL OR G.Descrizione Like '%' + @FiltroDescrizione + '%')

				-- accessi alle prestazioni, specifica o tutte
				AND EXISTS( SELECT * FROM @T T WHERE T.[Not] = 0
										AND (T.IdGruppoPrestazioni = G.ID
											OR T.IdGruppoPrestazioni IS NULL)
							 )

				--  accessi ai sistemi, specifico o tutti
				AND	EXISTS( SELECT * FROM @A A WHERE A.[Not] = 0
										AND A.[R] = 1
										AND (A.IDSistemaErogante <> '00000000-0000-0000-0000-000000000000'
											OR A.IDSistemaErogante IS NULL)
										AND (A.IDSistemaErogante = G.IDSistemaErogante
											OR A.IDSistemaErogante IS NULL)
							)

				-----------------------------------------------------------------------------------------
				-- ESCLUDE

				-- Esclude i gruppi prestazione, specifico o tutti, con NOT
				AND	NOT EXISTS ( SELECT * FROM @T T WHERE T.[Not] = 1
										AND (T.IdGruppoPrestazioni = G.ID
											OR T.IdGruppoPrestazioni IS NULL)
								)

				--  Esclude accessi ai sistemi, specifico o tutti, con NOT
				AND	NOT EXISTS ( SELECT * FROM @A A WHERE A.[Not] = 1
										AND A.[R] = 1
										AND (A.IDSistemaErogante <> '00000000-0000-0000-0000-000000000000'
											OR A.IDSistemaErogante IS NULL)
										AND (A.IDSistemaErogante = G.IDSistemaErogante
											OR A.IDSistemaErogante IS NULL)
								)
			) GRUPPI

		-- Modify date: 2016-05-03 - Usa SistemiEstesa per limitare le Query Distribuite
		INNER JOIN dbo.[SistemiEstesa] S ON S.ID = GRUPPI.IDSistemaErogante

	WHERE (S.Attivo = 1 OR S.ID = '00000000-0000-0000-0000-000000000000')

	GROUP BY GRUPPI.[Id], GRUPPI.[Descrizione], GRUPPI.[IDSistemaErogante]
	HAVING COUNT(GRUPPI.[IDPrestazione]) > 0

	ORDER BY GRUPPI.[Descrizione]

	--2018-02-07 Aggiunto OPTION (RECOMPILE)
	OPTION (RECOMPILE)
	
	RETURN 
END
