

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna la lista dei Ruoli di Accesso (attributi calcolati) di un utente di AD per AccountName
-- =============================================
CREATE PROC [organigramma_da].[AccessiOttienePerCodiceRuolo]
(
 @CodiceRuolo varchar(128)
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[AccessOttienePerCodiceRuolo]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[AccessOttienePerCodiceRuolo]!', 16, 1)
		RETURN
	END

	--Eseguo query
	SELECT	[Accesso]
	FROM  [organigramma_da].[RuoliAccesso]
	WHERE RuoloCodice = @CodiceRuolo
	ORDER BY RuoloCodice
END

