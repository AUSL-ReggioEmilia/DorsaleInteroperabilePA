

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-30
-- Description:	Ritorna la lista degli utenti (recursiva) di un gruppo di AD per AccountName
-- =============================================
CREATE PROC [organigramma_da].[UtentiOttienePerIdGruppo]
(
 @IdGruppo uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UtentiOttienePerGruppo]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UtentiOttienePerGruppo]!', 16, 1)
		RETURN
	END

	--Eseguo query
	SELECT DISTINCT 
		 IdFiglio AS IdUtente
		,UtenteFiglio AS Utente
	FROM [organigramma].[OttieneUtentiPerIdGruppo](@IdGruppo)
	ORDER BY UtenteFiglio
END

