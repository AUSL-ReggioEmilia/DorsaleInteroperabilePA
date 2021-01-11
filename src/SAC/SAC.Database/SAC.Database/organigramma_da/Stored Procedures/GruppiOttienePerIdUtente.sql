
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna la lista deii gruppi (recursiva) di un utente di AD per ID
-- =============================================
CREATE PROC [organigramma_da].[GruppiOttienePerIdUtente]
(
 @IdUtente uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[GruppiOttienePerIdUtente]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[GruppiOttienePerIdUtente]!', 16, 1)
		RETURN
	END

	--Eseguo query
	SELECT DISTINCT 
		 Gruppi.IdFiglio AS IdGruppo
		,Gruppi.UtenteFiglio AS Gruppo
	FROM [organigramma].[OttieneGruppiPerIdUtente](@IdUtente) Gruppi
	ORDER BY Gruppi.UtenteFiglio
END