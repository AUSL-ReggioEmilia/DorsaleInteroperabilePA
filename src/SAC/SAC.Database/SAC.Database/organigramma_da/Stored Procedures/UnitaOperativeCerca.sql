

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Cerca le unita operarive e ritorna una lista
-- =============================================
CREATE PROC [organigramma_da].[UnitaOperativeCerca]
(
 @Codice varchar(16) = NULL,
 @CodiceAzienda varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
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
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UnitaOperativeCerca]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UnitaOperativeCerca]!', 16, 1)
		RETURN
	END

	SELECT TOP (ISNULL(@Top, 100)) 
		[ID],
		[Codice],
		[CodiceAzienda],
		[Descrizione],
		[Attivo]
	FROM  [organigramma].[UnitaOperative]
	WHERE 
		(Codice LIKE @Codice + '%' OR @Codice IS NULL) AND 
		(CodiceAzienda LIKE @CodiceAzienda + '%' OR @CodiceAzienda IS NULL) AND 
		(Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND 
		(Attivo = @Attivo OR @Attivo IS NULL)
END


