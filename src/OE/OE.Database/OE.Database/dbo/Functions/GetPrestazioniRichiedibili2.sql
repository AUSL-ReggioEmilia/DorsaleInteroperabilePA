
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-11-03
-- Modify date: 2016-04-12 - Ritornano solo i profili con permesso esplicito
-- Modify date: 2016-04-20 - Esclusione dei profili con prestazioni di sistemi non abilitati
-- Modify date: 2016-04-29 - Abilitazione profili se ennupla tutte prestazioni
-- Modify date: 2016-05-03 - Usa SistemiEstesa per limitare le Query Distribuite
-- Modify date: 2016-10-06 - Usa OUTER APPLY delle gerarchie perchè filtra anche per P.Tipo
-- =============================================
-- Create date: 2016-07-14 - Copiata da [dbo].[GetPrestazioniRichiedibili]
--								Aggiunto parametro @dataoraRichiesta
--								Usa l anuova func dbo.GetEnnuple2, ha in più il parametro @dataoraRichiesta
-- Modify date: 2018-02-19 - Aggiunto parametri @FiltroIdGruppoPrestazioni, @FiltroTipoPrestazione e @FiltroTipoProfilo
--							 Corretto errore <> @utente invece che = @utente sezione profili except
-- Modify date: 2018-06-18 - Nuovo flag 'RichiedibileSoloDaProfilo'
--
-- Description:	Ritorna la lista delle prestazioni e profili richiedibili dall'utente
--					
-- =============================================
CREATE FUNCTION [dbo].[GetPrestazioniRichiedibili2]
(
  @Utente VARCHAR (64)
, @idUnitaOperativa UNIQUEIDENTIFIER
, @idSistemaRichiedente UNIQUEIDENTIFIER
, @dataoraRichiesta DATETIME
, @codiceRegime VARCHAR (16)
, @codicePriorita VARCHAR (16)
, @idStato TINYINT
, @FiltroIdSistemaErogante UNIQUEIDENTIFIER
, @FiltroCodiceDescrizione VARCHAR(256)
, @FiltroIdGruppoPrestazioni UNIQUEIDENTIFIER
, @FiltroTipoPrestazione BIT
, @FiltroTipoProfilo BIT
)
RETURNS 
    @Result TABLE (
        [ID]                UNIQUEIDENTIFIER NOT NULL,
        [Codice]            VARCHAR (16)     NOT NULL,
        [Descrizione]       VARCHAR (256)    NULL,
        [Tipo]              TINYINT          NOT NULL,
        [IDSistemaErogante] UNIQUEIDENTIFIER NOT NULL)
AS
BEGIN
	-- Controllo parametri
	SET @idStato = ISNULL(@idStato, 1)
	SET @FiltroCodiceDescrizione = NULLIF(@FiltroCodiceDescrizione, '')
	SET @FiltroIdSistemaErogante = NULLIF(@FiltroIdSistemaErogante, '00000000-0000-0000-0000-000000000000')
	SET @FiltroIdGruppoPrestazioni = NULLIF(@FiltroIdGruppoPrestazioni, '00000000-0000-0000-0000-000000000000')
	SET @FiltroTipoPrestazione = NULLIF(@FiltroTipoPrestazione, 0)
	SET @FiltroTipoProfilo = NULLIF(@FiltroTipoProfilo, 0)

	-- Tabella temporanea contenente le ennuple delle prestazioni
	DECLARE @T TABLE (IdGruppoPrestazioni uniqueidentifier, [Not] bit NOT NULL) 
	INSERT INTO @T 
		SELECT * FROM dbo.GetEnnuple2(@utente, @idUnitaOperativa, @idSistemaRichiedente, @dataoraRichiesta, @codiceRegime, @codicePriorita, @idStato)
			-- 2018-02-15 Filtro per Gruppo di prestazioni
			-- Solo IdGruppoPrestazioni o tutti se filtro è NULL o tutti gli IdGruppoPrestazioni NULL
		WHERE (IdGruppoPrestazioni = @FiltroIdGruppoPrestazioni
			 OR @FiltroIdGruppoPrestazioni IS NULL
			 OR IdGruppoPrestazioni IS NULL
			 )

	-- Tabella temporanea contenente le ennuple di accesso ai sistemi
	DECLARE @A TABLE (IDSistemaErogante uniqueidentifier, [R] bit NOT NULL, [I] bit NOT NULL, [S] bit NOT NULL, [Not] bit NOT NULL)
	INSERT INTO @A 
		SELECT * FROM dbo.GetEnnupleAccessi(@utente, @idStato)


	INSERT INTO @Result
	-- Tutte le prestazioni richiedibili eccetto le NOT
	-- Tutti i profili ADMIN richiedibili eccetto le NOT
	SELECT PREST.*
	FROM (
			-- Tutte le prestazioni richiedibili
			SELECT DISTINCT P_IN.*
			FROM
				(
					--Cerco tra prestazioni e profili (non utente) con diritti espliciti
					SELECT P.ID, P.Codice, P.Descrizione, P.Tipo, P.IDSistemaErogante
					FROM Prestazioni P
		 				INNER JOIN PrestazioniGruppiPrestazioni PGP ON PGP.IDPrestazione = P.ID
						INNER JOIN @T T ON T.IdGruppoPrestazioni = PGP.IDGruppoPrestazioni
					WHERE  T.[Not] = 0
						AND P.Attivo = 1
						AND P.RichiedibileSoloDaProfilo = 0									--2018-06-18: Escludo se flag
						AND P.Tipo <> 3														--2016-04-29: Anche profili

					UNION 
				
					--Abilitazione totale sulle prestazioni e profili
					SELECT P.ID, P.Codice, P.Descrizione, P.Tipo, P.IDSistemaErogante
					FROM Prestazioni P
					WHERE P.Attivo = 1
						AND P.RichiedibileSoloDaProfilo = 0									--2018-06-18: Escludo se flag
						AND P.Tipo <> 3														--2016-04-29: Anche profili
						AND EXISTS(SELECT * FROM @T T WHERE T.IdGruppoPrestazioni IS NULL
											AND T.[Not] = 0 )

				) P_IN
				
			WHERE -- Filtro per Codice e Sistema Erogante
					(@FiltroIdSistemaErogante IS NULL OR P_IN.IDSistemaErogante = @FiltroIdSistemaErogante)	
				AND (@FiltroCodiceDescrizione IS NULL OR (P_IN.Codice Like '%' + @FiltroCodiceDescrizione + '%' 
															OR P_IN.Descrizione Like '%' + @FiltroCodiceDescrizione + '%')
														)

				AND	 --  Filtro per accessi ai sistemi
 					(
							--Abilitazione totale su tutti i sistemi
							EXISTS (SELECT * FROM @A A WHERE A.[R] = 1 AND A.IDSistemaErogante IS NULL
										AND A.[Not] = 0)

						OR
 							-- Includo prestazione se è di un sistema abilitato
							EXISTS( SELECT * FROM @A A WHERE A.IDSistemaErogante = P_IN.IDSistemaErogante
										AND A.IDSistemaErogante <> '00000000-0000-0000-0000-000000000000'
										AND A.[R] = 1
										AND A.[Not] = 0
									)
						OR 
							--2016-04-12 - Ritornano solo i profili con permesso esplicito
							-- Includo i profili
							P_IN.IDSistemaErogante = '00000000-0000-0000-0000-000000000000'
					)
							
			AND --2018-02-15 Filtro per Tipo 
				(
				   (P_IN.Tipo = 0 AND @FiltroTipoPrestazione = 1)
				OR (P_IN.Tipo <> 0 AND @FiltroTipoProfilo = 1)
				)
	
		------------------------EXCEPT--------------------------------------------
		EXCEPT
			-- Tutte le prestazioni non richiedibili
			-- Escluse tutte le prestazioni o profili con ennuple in [Not] 
			SELECT P.ID, P.Codice, P.Descrizione, P.Tipo, P.IDSistemaErogante
			FROM Prestazioni P
			WHERE P.Attivo = 1
				AND P.RichiedibileSoloDaProfilo = 0									--2018-06-18: Escludo se flag
				AND (
						-- Include le prestazione con NOT
						EXISTS ( SELECT * FROM PrestazioniGruppiPrestazioni PGP
												INNER JOIN @T T ON T.IdGruppoPrestazioni = PGP.IDGruppoPrestazioni
											WHERE PGP.IDPrestazione = P.ID
												AND T.[Not] = 1)
					OR
						--Disabilitazione totale su tutti i gruppoi
						EXISTS ( SELECT * FROM @T T WHERE T.IdGruppoPrestazioni IS NULL
											AND T.[Not] = 1)
					OR 
						--Disabilitazione totale su tutti i sistemi
						EXISTS ( SELECT * FROM @A A WHERE A.[R] = 1 AND A.IDSistemaErogante IS NULL
											AND A.[Not] = 1)

					OR
						--2016-04-20 - Esclusione
						-- Profili con prestazioni non richiedibili
						EXISTS( SELECT *
								FROM [dbo].[GetProfiloGerarchia2](P.ID) G
								WHERE G.Attivo = 1
									AND G.Tipo = 0
									AND NOT (
											-- accessi ai sistemi
											(EXISTS (
													SELECT * FROM @A A
													WHERE A.IDSistemaErogante = G.IDSistemaErogante
															AND A.[R] = 1
															AND A.[Not] = 0
													)
											-- accesso totale ai sistemi		
											OR EXISTS (SELECT * FROM @A A WHERE A.IDSistemaErogante IS NULL
															AND A.[Not] = 0)

											) 
											-- Escluso per sistemi
											AND NOT (
													-- Inibizione ai sistemi
													EXISTS (
															SELECT * FROM @A A
															WHERE A.IDSistemaErogante = G.IDSistemaErogante
																	AND A.[R] = 1
																	AND A.[Not] = 1
															)
													-- Inibizione totale ai sistemi		
													OR EXISTS (SELECT * FROM @A A WHERE A.IDSistemaErogante IS NULL
																	AND A.[Not] = 1)
													)
											)
							)

					)
			) PREST

		--2016-05-03 - Usa SistemiEstesa per limitare le Query Distribuite
		INNER JOIN SistemiEstesa S ON S.ID = PREST.IDSistemaErogante
	WHERE (S.Attivo = 1 OR S.ID = '00000000-0000-0000-0000-000000000000')
		
		AND	 --2018-02-15 Filtro per GruppoPrestazioni 
			(
			EXISTS (
					SELECT * FROM PrestazioniGruppiPrestazioni PGP
					WHERE PGP.IDPrestazione = PREST.ID
						AND PGP.IdGruppoPrestazioni = @FiltroIdGruppoPrestazioni
					)

			OR @FiltroIdGruppoPrestazioni IS NULL
			)

	UNION

	-- Tutte i Profili richiedibili eccetto le NOT
	--	con permessi ereditati dalle prestazioni (profilo dove si ha accesso a tutte le sue prestazioni)	
	--2016-04-12 - Ritornano solo i profili con permesso esplicito (non permessi ereditati per ADMIN)
	--				ma solo per i personali
	--
	SELECT PROF.*
	FROM (	
		
		-- Tutte i Profili richiedibili personali
		SELECT DISTINCT  P.ID, P.Codice, P.Descrizione, P.Tipo, P.IDSistemaErogante
		FROM Prestazioni P
			OUTER APPLY [dbo].[GetProfiloGerarchia2](P.ID) G
			
		WHERE P.Attivo = 1
			AND G.Attivo = 1
			AND G.Tipo = 0
			
			-- Filtro per sistemi eroganti delle prestazioni e/o codice descrizione del profilo
			AND (@FiltroIdSistemaErogante IS NULL OR G.IDSistemaErogante = @FiltroIdSistemaErogante)	
			AND (@FiltroCodiceDescrizione IS NULL OR (P.Codice Like '%' + @FiltroCodiceDescrizione + '%' 
														OR P.Descrizione Like '%' + @FiltroCodiceDescrizione + '%')
														)
			--2016-04-12 - Ritornano solo i profili con permesso esplicito
			--	Solo profili personali miei
			AND (
					--( P.Tipo = 1 OR P.Tipo = 2) OR
					( P.Tipo = 3 AND P.UtenteModifica = @utente)
				)

			-- Filtro per accessi alle prestazioni
			AND (
				EXISTS (
						SELECT * FROM PrestazioniGruppiPrestazioni PGP
							INNER JOIN @T T ON T.IdGruppoPrestazioni = PGP.IDGruppoPrestazioni
						WHERE PGP.IDPrestazione = G.IDFiglio
							AND T.[Not] = 0
						)
						
				-- Accesso totale ai gruppi	di prestazioni	
				OR EXISTS (SELECT * FROM @T T WHERE IdGruppoPrestazioni IS NULL
										AND T.[Not] = 0)
				)
			
			-- Filtro per accessi ai sistemi		
			AND (
				EXISTS (
						SELECT * FROM @A A
						WHERE A.IDSistemaErogante = G.IDSistemaErogante
								AND A.[R] = 1
								AND A.[Not] = 0
						)
				-- accesso totale ai sistemi		
				OR EXISTS (SELECT * FROM @A A WHERE A.IDSistemaErogante IS NULL
								AND A.[Not] = 0)
				)

			AND --2018-02-15 Filtro per TipoProfilo 
				(@FiltroTipoProfilo = 1)
			
		GROUP BY P.ID, P.Codice, P.Descrizione, P.Tipo, P.IDSistemaErogante
		
		-- Tutte le prestaziuoni richiedibili
		HAVING COUNT(G.IDFiglio) = (SELECT COUNT(*) FROM [dbo].[GetProfiloGerarchia2](P.ID) G_ALL
									WHERE G_ALL.Attivo = 1 AND G_ALL.Tipo = 0)

		------------------------EXCEPT--------------------------------------------
		EXCEPT

		SELECT DISTINCT  P.ID, P.Codice, P.Descrizione, P.Tipo, P.IDSistemaErogante
		FROM Prestazioni P
			OUTER APPLY [dbo].[GetProfiloGerarchia2](P.ID) G
			
		WHERE  P.Attivo = 1
			AND G.Attivo = 1
			AND G.Tipo = 0

			--2016-04-12 - Ritornano solo i profili con permesso esplicito
			--	Solo profili personali miei
			--2018-02-19 corretto errore <> @utente invece che = @utente
			AND (
					--( P.Tipo = 1 OR P.Tipo = 2) OR
					( P.Tipo = 3 AND P.UtenteModifica = @utente)
				)
							
			AND (
					-- Filtro per accessi alle prestazioni
					EXISTS (
							SELECT * FROM PrestazioniGruppiPrestazioni PGP
								INNER JOIN @T T ON T.IdGruppoPrestazioni = PGP.IDGruppoPrestazioni
							WHERE PGP.IDPrestazione = G.IDFiglio
								AND T.[Not] = 1
							)
				
				OR -- Filtro per accessi ai sistemi		
					EXISTS (
							SELECT * FROM @A A
							WHERE A.IDSistemaErogante = G.IDSistemaErogante
									AND A.[R] = 1
									AND A.[Not] = 1
							)
							
				OR 	--Abilitazione totale su tutti i sistemi
					EXISTS (SELECT * FROM @A A 
							WHERE A.IDSistemaErogante IS NULL
									AND A.[R] = 1
									AND A.[Not] = 1)
				)
		GROUP BY P.ID, P.Codice, P.Descrizione, P.Tipo, P.IDSistemaErogante
		
		-- Tutte le prestaziuoni richiedibili
		HAVING COUNT(G.IDFiglio) = (SELECT COUNT(*) FROM [dbo].[GetProfiloGerarchia2](P.ID) G_ALL
									WHERE G_ALL.Attivo = 1 AND G_ALL.Tipo = 0)

		) PROF

		--2016-05-03 - Usa SistemiEstesa per limitare le Query Distribuite
		INNER JOIN SistemiEstesa S ON S.ID = PROF.IDSistemaErogante

	WHERE (S.Attivo = 1 OR S.ID = '00000000-0000-0000-0000-000000000000')

		AND	 --2018-02-15 Filtro per GruppoPrestazioni 
			(
			EXISTS (
					SELECT * FROM PrestazioniGruppiPrestazioni PGP
					WHERE PGP.IDPrestazione = PROF.ID
						AND PGP.IdGruppoPrestazioni = @FiltroIdGruppoPrestazioni
					)

			OR @FiltroIdGruppoPrestazioni IS NULL
			)

	ORDER BY Codice

	OPTION (RECOMPILE)	

	RETURN 
END