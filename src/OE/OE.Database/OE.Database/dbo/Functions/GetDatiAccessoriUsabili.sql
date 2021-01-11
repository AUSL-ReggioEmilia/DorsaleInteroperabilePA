
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2017-02-23 - Copiata da [dbo].[GetPrestazioniRichiedibili2]
-- Modify date: 2017-11-27 - SANDRO: Abilitazione dei DatiAccessori senza Ennupla specifica
-- Modify date: 2018-07-27 - SANDRO: Aggiunto 	OPTION (RECOMPILE)
--
-- Description:	Ritorna la lista dei DatiAccessori usabili dall'utente
-- =============================================
CREATE FUNCTION [dbo].[GetDatiAccessoriUsabili]
(
  @Utente VARCHAR (64)
, @idUnitaOperativa UNIQUEIDENTIFIER
, @idSistemaRichiedente UNIQUEIDENTIFIER
, @dataoraRichiesta DATETIME
, @codiceRegime VARCHAR (16)
, @codicePriorita VARCHAR (16)
, @idStato TINYINT
, @FiltroCodiceDescrizione VARCHAR (256)
)
RETURNS 
    @Result TABLE (
        [Codice]            VARCHAR (64)     NOT NULL,
        [Descrizione]       VARCHAR (256)    NULL,
        [Etichetta]         VARCHAR (64)     NULL,
        [Tipo]              VARCHAR (32)     NOT NULL)
AS
BEGIN
	-- Controllo parametri
	SET @FiltroCodiceDescrizione = NULLIF(@FiltroCodiceDescrizione, '')
	SET @idStato = ISNULL(@idStato, 1)

	-- Tabella temporanea contenente le ennuple delle prestazioni
	DECLARE @T TABLE (CodiceDatiAccessori varchar(64), [Not] bit NOT NULL) 
	INSERT INTO @T 
		SELECT * FROM dbo.GetEnnupleDatiAccessori(@utente, @idUnitaOperativa, @idSistemaRichiedente, @dataoraRichiesta, @codiceRegime, @codicePriorita, @idStato)

	INSERT INTO @Result
	-- Tutte le prestazioni richiedibili eccetto le NOT
	SELECT DatiAcc.*
	FROM (
			-- Tutte le prestazioni richiedibili
			SELECT DISTINCT DA_IN.*
			FROM
				(
					--Cerco tra DatiAccessori con diritti espliciti
					SELECT P.Codice, P.Descrizione, P.Etichetta, P.Tipo
					FROM [dbo].[DatiAccessori] P
						INNER JOIN @T T ON T.CodiceDatiAccessori = P.Codice
					WHERE  T.[Not] = 0
					
					UNION 
				
					--Abilitazione totale su DatiAccessori
					SELECT P.Codice, P.Descrizione, P.Etichetta, P.Tipo
					FROM [dbo].[DatiAccessori] P
					WHERE EXISTS(SELECT * FROM @T T WHERE T.CodiceDatiAccessori IS NULL
											AND T.[Not] = 0 )

					UNION 
				
					--2017-11-27 - Abilitazione dei DatiAccessori senza Ennupla specifica abilitata
					SELECT P.Codice, P.Descrizione, P.Etichetta, P.Tipo
					FROM [dbo].[DatiAccessori] P
					WHERE NOT EXISTS( SELECT * FROM [dbo].[EnnupleDatiAccessori]
											WHERE [CodiceDatoAccessorio] = P.Codice
												AND IDStato = 1)

				) DA_IN
				
			WHERE -- Filtro per Codice e Sistema Erogante
				 (@FiltroCodiceDescrizione IS NULL OR (DA_IN.Codice Like '%' + @FiltroCodiceDescrizione + '%' 
															OR DA_IN.Descrizione Like '%' + @FiltroCodiceDescrizione + '%')
														)
				
		------------------------EXCEPT--------------------------------------------
		EXCEPT
			-- Tutti i DatiAccessori non usabili
			-- Escluse tutte quelli con ennuple in [Not] 
			SELECT P.Codice, P.Descrizione, P.Etichetta, P.Tipo
			FROM [dbo].[DatiAccessori] P

			WHERE (
						-- Include le prestazione con NOT
						EXISTS ( SELECT * FROM @T T	WHERE T.CodiceDatiAccessori = P.Codice
												AND T.[Not] = 1)
					OR
						--Disabilitazione totale su tutti i gruppoi
						EXISTS ( SELECT * FROM @T T WHERE T.CodiceDatiAccessori IS NULL
												AND T.[Not] = 1)

					)
			) DatiAcc

	ORDER BY Codice
	
	-- 2018-07-27
	OPTION (RECOMPILE)

	RETURN 
END