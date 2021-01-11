

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Cerca un utente di AD e ritorna una lista
-- =============================================
CREATE PROC [organigramma_da].[UtentiCerca]
(
 @Utente varchar(128) = NULL,
 @Descrizione varchar(256) = NULL,
 @Cognome varchar(64) = NULL,
 @Nome varchar(64) = NULL,
 @CodiceFiscale varchar(16) = NULL,
 @Matricola varchar(64) = NULL,
 @Email varchar(256) = NULL,
 @Attivo bit = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UtentiCerca]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UtentiCerca]!', 16, 1)
		RETURN
	END

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
	FROM  [organigramma_da].[Utenti]
	WHERE 
		(Utente LIKE '%' + @Utente + '%' OR @Utente IS NULL) AND 
		(Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND 
		(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL) AND 
		(Nome LIKE @Nome + '%' OR @Nome IS NULL) AND 
		(CodiceFiscale LIKE @CodiceFiscale + '%' OR @CodiceFiscale IS NULL) AND 
		(Matricola LIKE @Matricola + '%' OR @Matricola IS NULL) AND 
		(Email LIKE @Email + '%' OR @Email IS NULL) AND
		(Attivo = @Attivo OR @Attivo IS NULL)
END

