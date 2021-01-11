-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-08
-- Description:	Ricerca Utenti di AD, ritorna una lista
-- =============================================
CREATE PROC [organigramma_ws].[UtentiCerca]
(
 @Top INT = NULL,
 @Ordinamento varchar(128) = NULL,
 @Utente varchar(128) = NULL,
 @Descrizione varchar(256) = NULL,
 @Cognome varchar(64) = NULL,
 @Nome varchar(64) = NULL,
 @CodiceFiscale varchar(16) = NULL,
 @Matricola varchar(64) = NULL,
 @Email varchar(256) = NULL,
 @Attivo bit = NULL,
 @CodiceRuolo varchar(16) = NULL
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON
	--
	-- Imposto '' per l'ordinamento di default
	--
	SET @Ordinamento = ISNULL(@Ordinamento,'')

	--Eseguo query
	SELECT TOP (ISNULL(@Top, 100)) 
		[Id],
		[Utente],
		[Descrizione],
		[Cognome],
		[Nome],
		[CodiceFiscale],
		[Matricola],
		[Email],
		[Attivo]
	FROM  [organigramma_ws].[Utenti]
	WHERE 
		(Utente LIKE '%' + @Utente + '%' OR @Utente IS NULL) AND 
		(Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND 
		(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL) AND 
		(Nome LIKE @Nome + '%' OR @Nome IS NULL) AND 
		(CodiceFiscale LIKE @CodiceFiscale + '%' OR @CodiceFiscale IS NULL) AND 
		(Matricola LIKE @Matricola + '%' OR @Matricola IS NULL) AND 
		(Email LIKE @Email + '%' OR @Email IS NULL) AND
		(Attivo = @Attivo OR @Attivo IS NULL)
		AND 
		(
			(@CodiceRuolo IS NULL)
			OR --EVENTUALE FILTRO SUL RUOLO UTENTE
			(@CodiceRuolo IS NOT NULL
			 AND @CodiceRuolo IN (SELECT RU.RuoloCodice
									FROM [organigramma_ws].[RuoliUtenti] as RU
									WHERE RU.IdUtente=[organigramma_ws].[Utenti].Id)
			)
		)

	ORDER BY 	
		--Default
		CASE @Ordinamento WHEN '' THEN [Utente] END ASC
		--Ascendente	
		, CASE @Ordinamento WHEN 'CognomeNome@ASC' THEN [Cognome] END ASC
		, CASE @Ordinamento WHEN 'CognomeNome@ASC' THEN [Nome] END ASC
		, CASE @Ordinamento WHEN 'Utente@ASC' THEN [Utente] END ASC
		, CASE @Ordinamento WHEN 'Attivo@ASC' THEN Attivo END ASC
		--Discendente	
		, CASE @Ordinamento WHEN 'CognomeNome@DESC' THEN [Cognome] END DESC
		, CASE @Ordinamento WHEN 'CognomeNome@DESC' THEN [Nome] END DESC
		, CASE @Ordinamento WHEN 'Utente@DESC' THEN [Utente] END DESC
		, CASE @Ordinamento WHEN 'Attivo@DESC' THEN Attivo END DESC
	
	OPTION(RECOMPILE)
END