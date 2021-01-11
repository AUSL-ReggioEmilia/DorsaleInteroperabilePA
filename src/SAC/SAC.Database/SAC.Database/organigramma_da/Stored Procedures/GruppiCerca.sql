


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Cerca nei gruppi di AD e ritorna una lista
-- =============================================
CREATE PROC [organigramma_da].[GruppiCerca]
(
 @Gruppo varchar(128) = NULL,
 @Descrizione varchar(256) = NULL,
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
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[GruppiCerca]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[GruppiCerca]!', 16, 1)
		RETURN
	END

	--Eseguo query
	SELECT TOP (ISNULL(@Top, 100)) 
		[Id],
		[Gruppo],
		[Descrizione],
		[Attivo]
	FROM  [organigramma_da].[Gruppi]
	WHERE 
		(Gruppo LIKE '%' + @Gruppo + '%' OR @Gruppo IS NULL) AND 
		(Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND
		(Attivo = @Attivo OR @Attivo IS NULL)
END

