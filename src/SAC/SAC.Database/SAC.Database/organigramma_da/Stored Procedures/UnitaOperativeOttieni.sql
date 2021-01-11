

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna una UO per codice
-- =============================================
CREATE PROC [organigramma_da].[UnitaOperativeOttieni]
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
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UnitaOperativeOttieni]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UnitaOperativeOttieni]!', 16, 1)
		RETURN
	END

	SELECT 
		[ID],
		[Codice],
		[CodiceAzienda],
		[Descrizione],
		[Attivo]
	FROM  [organigramma].[UnitaOperative]
	WHERE [Codice] = @Codice
		AND [CodiceAzienda] = @CodiceAzienda
END


