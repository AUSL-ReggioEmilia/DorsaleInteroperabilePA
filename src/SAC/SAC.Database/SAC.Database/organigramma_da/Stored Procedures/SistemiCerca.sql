

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Cerca un sistema e ritorna una lista
-- =============================================
CREATE PROC [organigramma_da].[SistemiCerca]
(
 @Codice varchar(16) = NULL,
 @CodiceAzienda varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
 @Erogante bit = NULL,
 @Richiedente bit = NULL,
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
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[SistemiCerca]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[SistemiCerca]!', 16, 1)
		RETURN
	END

	SELECT TOP (ISNULL(@Top, 100)) 
		[ID],
		[Codice],
		[CodiceAzienda],
		[Descrizione],
		[Erogante],
		[Richiedente],
		[Attivo]
	FROM  [organigramma].[Sistemi]
	WHERE 
		(Codice LIKE @Codice + '%' OR @Codice IS NULL) AND 
		(CodiceAzienda LIKE @CodiceAzienda + '%' OR @CodiceAzienda IS NULL) AND 
		(Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND 
		(Erogante = @Erogante OR @Erogante IS NULL) AND 
		(Richiedente = @Richiedente OR @Richiedente IS NULL) AND 
		(Attivo = @Attivo OR @Attivo IS NULL)
END


