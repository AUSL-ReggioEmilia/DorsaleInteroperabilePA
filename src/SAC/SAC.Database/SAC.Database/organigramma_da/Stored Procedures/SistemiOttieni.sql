

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna un sistema per codice
-- =============================================
CREATE PROC [organigramma_da].[SistemiOttieni]
(
 @Codice varchar(16),
 @CodiceAzienda varchar(16)
)
AS
BEGIN
SET NOCOUNT OFF

  	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[SistemiOttieni]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[SistemiOttieni]!', 16, 1)
		RETURN
	END

	SELECT 
		[ID],
		[Codice],
		[CodiceAzienda],
		[Descrizione],
		[Erogante],
		[Richiedente],
		[Attivo]
	FROM  [organigramma].[Sistemi]
	WHERE [Codice] = @Codice
		AND [CodiceAzienda] = @CodiceAzienda
END



