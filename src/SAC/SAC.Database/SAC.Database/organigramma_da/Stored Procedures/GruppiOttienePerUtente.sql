

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna la lista deii gruppi (recursiva) di un utente di AD per AccountName
-- =============================================
CREATE PROC [organigramma_da].[GruppiOttienePerUtente]
(
 @Utente varchar(128)
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[GruppiOttienePerUtente]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[GruppiOttienePerUtente]!', 16, 1)
		RETURN
	END

	--Eseguo query
	SELECT DISTINCT 
		 Gruppi.IdFiglio AS IdGruppo
		,Gruppi.UtenteFiglio AS Gruppo
	FROM [organigramma].[OttieneGruppiPerUtente](@Utente) Gruppi
	ORDER BY Gruppi.UtenteFiglio
END