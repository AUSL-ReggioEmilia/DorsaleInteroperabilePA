-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-02-27
-- Modify date: 2018-06-27 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
--										Rimosso WITH RECOMPILE e aggiunto OPTION (RECOMPILE)
--								   Aggiunto campo RichiedibileSoloDaProfilo
--								   Modifica selezione GetEnnupleAccessi()
--
-- Description:	Seleziona le prestazioni per ID verificando l'erogabilità
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniCheckByIds]
	  @ids varchar(max)
	, @utente varchar(64)
	, @idUnitaOperativa uniqueidentifier
	, @idSistemaRichiedente uniqueidentifier
	, @codiceRegime varchar(16)
	, @codicePriorita varchar(16)
	, @accesso varchar(1) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- Imposta il primo giorno della settimana il lunedi
	SET DATEFIRST 1
	
	DECLARE @idStato tinyint = 1
	DECLARE @escludeProfiliAltriUtenti bit = 0

	-- Verifico parametro accesso
	IF @accesso IS NULL
		SET @accesso = 'R'
		
	IF NOT @accesso IN ('R', 'I', 'S') 
		RAISERROR ('Parametro @accesso errato! valori permessi R, I, S.', 16, 1)

	-- SPLIT del paramentero ID
	DECLARE @Value varchar(50), @Pos int
	DECLARE @tblPrestazioni TABLE (ID uniqueidentifier, IdPadre uniqueidentifier)

	SET @ids = LTRIM(RTRIM(@ids))+ ','
	SET @Pos = CHARINDEX(',', @ids, 1)

	IF REPLACE(@ids, ',', '') <> ''
	BEGIN
		WHILE @Pos > 0
		BEGIN
			SET @Value = LTRIM(RTRIM(LEFT(@ids, @Pos - 1)))
			
			IF @Value <> '' AND dbo.IsGuid(@Value) = 1
			BEGIN
				-- Aggingo la prestazione o il profilo
				INSERT INTO @tblPrestazioni (ID, IdPadre)
					SELECT ID, @Value AS IdPadre FROM Prestazioni
					WHERE ID = @Value
			END
			
			SET @ids = RIGHT(@ids, LEN(@ids) - @Pos)
			SET @Pos = CHARINDEX(',', @ids, 1)
		END
	END
			
	-- Tabella temporanea contenente le ennuple delle prestazioni
	DECLARE @T TABLE (IdGruppoPrestazioni uniqueidentifier, [Not] bit NOT NULL) 
	INSERT INTO @T 
		SELECT * FROM dbo.GetEnnuple(@utente, @idUnitaOperativa, @idSistemaRichiedente, NULL, @codiceRegime, @codicePriorita, @idStato)

	-- Tabella temporanea contenente le ennuple di accesso ai sistemi
	-- Seleziona campo in base al tipo di accesso
	--
	DECLARE @A TABLE (IDSistemaErogante uniqueidentifier, [Accesso] bit NOT NULL, [Not] bit NOT NULL)
	INSERT INTO @A
		SELECT IDSistemaErogante
			, CASE WHEN @accesso = 'R' THEN [R]
					WHEN @accesso = 'I' THEN [I]
					WHEN @accesso = 'S' THEN [S]
					ELSE [R] END AS [Accesso]
			, [Not]
		FROM dbo.GetEnnupleAccessi(@utente, @idStato)

	-- Tutte le prestazioni con diritto di lettura
	SELECT DISTINCT P1.* FROM
		(
			-- Abilitazioni specifiche
			SELECT P.ID, P.Codice, P.Descrizione, P.Tipo, P.IDSistemaErogante
				, S.CodiceAzienda AS CodiceAzienda, A.Descrizione AS DescrizioneAzienda
				, S.Codice AS CodiceSistema, S.Descrizione AS DescrizioneSistema
				, P.RichiedibileSoloDaProfilo

			FROM Prestazioni P
				INNER JOIN Sistemi S ON P.IDSistemaErogante = S.ID
				INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda

				--Filtro per le prastazioni da verificare
				INNER JOIN @tblPrestazioni PL ON PL.ID = P.ID

			WHERE P.Attivo = 1
				AND (S.Attivo = 1 OR S.ID = '00000000-0000-0000-0000-000000000000')
				
				-- NO profili personali di altri utenti se abilitato @escludeProfiliAltriUtenti
				AND (NOT (P.Tipo = 3 AND P.UtenteInserimento <> @utente) OR @escludeProfiliAltriUtenti = 0)

				---------------------------------------------------------------------
				--            Filtro per accessi alle prestazioni e gruppi
				---------------------------------------------------------------------
				AND(
					(
					-- Include le prestazione accessibili
					EXISTS ( SELECT *
						FROM PrestazioniGruppiPrestazioni PGP_IN 
								INNER JOIN @T T_IN ON T_IN.IdGruppoPrestazioni = PGP_IN.IDGruppoPrestazioni
						WHERE PGP_IN.IDPrestazione = P.ID
							AND T_IN.[Not] = 0
							)
					)
					OR				
					(
		 			--SE almeno una prestazione del profile è accessibili e nessuna non è accessibili = tutte le prestazioni sono accessibili
 					-- Includo profilo se almeno una prestazione è di un gruppo abilitato
					EXISTS ( SELECT *
						FROM [dbo].[GetProfiloGerarchia2](P.ID) G_IN
								INNER JOIN PrestazioniGruppiPrestazioni PGP_IN ON G_IN.IDFiglio = PGP_IN.IDPrestazione
								INNER JOIN @T T_IN ON T_IN.IdGruppoPrestazioni = PGP_IN.IDGruppoPrestazioni
						WHERE G_IN.Attivo = 1
							AND G_IN.Tipo = 0
							AND T_IN.[Not] = 0
							)
 					-- Escludo profilo se almeno una prestazione NON è di un gruppo abilitato
					AND NOT EXISTS ( 
								SELECT G_ALL.*
									FROM [dbo].[GetProfiloGerarchia2](P.ID) G_ALL
									WHERE G_ALL.Attivo = 1
										AND G_ALL.Tipo = 0
								EXCEPT
								SELECT G_IN.*
									FROM [dbo].[GetProfiloGerarchia2](P.ID) G_IN
											INNER JOIN PrestazioniGruppiPrestazioni PGP_IN ON G_IN.IDFiglio = PGP_IN.IDPrestazione
											INNER JOIN @T T_IN ON T_IN.IdGruppoPrestazioni = PGP_IN.IDGruppoPrestazioni
									WHERE G_IN.Attivo = 1
										AND G_IN.Tipo = 0
										AND T_IN.[Not] = 0							
							)
					)
					--Abilitazione totale
					OR (SELECT COUNT(*) FROM @T T_ALL WHERE T_ALL.[Not] = 0 AND T_ALL.IdGruppoPrestazioni IS NULL) > 0
					)
		) P1
	WHERE
			------------------------------------------------------
			--             Filtro per accessi ai sistemi
			------------------------------------------------------
 		(
 			( 
 			--SE almeno una prestazione del profile è accessibili e nessuna non è accessibili = tutte le prestazioni sono accessibili
			-- Includo profilo almeno una prestazione è di un sistema abilitato
			EXISTS( SELECT * FROM [dbo].[GetProfiloGerarchia2](P1.ID) G_FIN
						INNER JOIN @A A_FIN ON A_FIN.IDSistemaErogante = G_FIN.IDSistemaErogante
					WHERE G_FIN.Tipo = 0
						AND A_FIN.[Not] = 0
						AND A_FIN.[Accesso] = 1
					)
			-- Escludo profilo se almeno una prestazione NON è di un sistema abilitato
			AND NOT EXISTS( SELECT G_FALL.* FROM [dbo].[GetProfiloGerarchia2](P1.ID) G_FALL
											WHERE G_FALL.Tipo = 0
							EXCEPT
							SELECT G_FIN.* FROM [dbo].[GetProfiloGerarchia2](P1.ID) G_FIN
												INNER JOIN @A A_FIN ON A_FIN.IDSistemaErogante = G_FIN.IDSistemaErogante
											WHERE G_FIN.Tipo = 0
												AND A_FIN.[Not] = 0
												AND A_FIN.[Accesso] = 1
						)
			)
			OR
				--Abilitazione totale su tutti i sistemi
				EXISTS (SELECT * FROM @A A WHERE A.[Not] = 0 AND A.[Accesso] = 1 AND A.IDSistemaErogante IS NULL)

			OR
 				-- Includo prestazione se è di un sistema abilitato
				EXISTS( SELECT * FROM @A A_FIN
						WHERE A_FIN.IDSistemaErogante = P1.IDSistemaErogante
							AND A_FIN.IDSistemaErogante <> '00000000-0000-0000-0000-000000000000'
							AND A_FIN.[Not] = 0
							AND A_FIN.[Accesso] = 1
						)
		)
		AND
			--Disabilitazione totale su tutti i gruppoi
			NOT EXISTS ( SELECT * FROM @T T WHERE T.[Not] = 1 AND T.IdGruppoPrestazioni IS NULL)
		AND 
			--Disabilitazione totale su tutti i sistemi
			NOT EXISTS ( SELECT * FROM @A A WHERE A.[Not] = 1 AND A.[Accesso] = 1 AND A.IDSistemaErogante IS NULL)

	EXCEPT
	------------------------EXCEPT--------------------------------------------
	-- Escluse tutte le prestazioni con ennuple in [Not] 

	SELECT P.ID, P.Codice, P.Descrizione, P.Tipo, P.IDSistemaErogante
			, S.CodiceAzienda AS CodiceAzienda, A.Descrizione AS DescrizioneAzienda
			, S.Codice AS CodiceSistema, S.Descrizione AS DescrizioneSistema
			, P.RichiedibileSoloDaProfilo

	FROM Prestazioni P
		INNER JOIN Sistemi S ON P.IDSistemaErogante = S.ID
		INNER JOIN Aziende A ON A.Codice = S.CodiceAzienda	
		
		--Filtro per le prastazioni da verificare
		INNER JOIN @tblPrestazioni PL ON PL.ID = P.ID
	WHERE 
			-- Include gerarchie con ennuple prestazioni NOT
			EXISTS( SELECT * FROM [dbo].[GetProfiloGerarchia2](P.ID) G_IN
									INNER JOIN PrestazioniGruppiPrestazioni PGP_IN ON G_IN.IDFiglio = PGP_IN.IDPrestazione
									INNER JOIN @T T_IN ON T_IN.IdGruppoPrestazioni = PGP_IN.IDGruppoPrestazioni
									INNER JOIN Prestazioni PP ON G_IN.IDPadre = PP.ID
								WHERE PP.Tipo <> 0
									AND T_IN.[Not] = 1)
		OR
			-- Include gerarchie con ennuple sistemi NOT
			EXISTS( SELECT * FROM [dbo].[GetProfiloGerarchia2](P.ID) G_IN
									INNER JOIN @A A_IN ON A_IN.IDSistemaErogante = G_IN.IDSistemaErogante
									INNER JOIN Prestazioni PP ON G_IN.IDPadre = PP.ID
								WHERE PP.Tipo <> 0
									AND A_IN.[Not] = 1
									AND A_IN.[Accesso] = 1)
		OR						
			-- Include le prestazione con NOT
			EXISTS ( SELECT * FROM PrestazioniGruppiPrestazioni PGP_IN 
									INNER JOIN @T T_IN ON T_IN.IdGruppoPrestazioni = PGP_IN.IDGruppoPrestazioni
								WHERE PGP_IN.IDPrestazione = P.ID
									AND T_IN.[Not] = 1)

	--------------------------------------------------------------------------
	----------------------------EXCEPT----------------------------------------
	ORDER BY P1.Codice

	-- Modify date: 2018-06-27 SANDRO: Problema saltuario di time-out invece che quanche sec di exec
	OPTION (RECOMPILE)

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniCheckByIds] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniCheckByIds] TO [DataAccessWs]
    AS [dbo];

