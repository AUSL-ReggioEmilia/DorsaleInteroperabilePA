

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Modify date: 2016-11-25 Aggiunto campo Attivo
-- Description:	Ritorna il gruppi di AD per Id
-- =============================================
CREATE PROC [organigramma_da].[GruppiOttienePerId]
(
 @Id uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[GruppiOttienePerId]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[GruppiOttienePerId]!', 16, 1)
		RETURN
	END

	--Eseguo query
	SELECT
		[Id],
		[Gruppo],
		[Descrizione],
		[Attivo]
	FROM [organigramma_da].[Gruppi]
	WHERE Id = @Id
END


