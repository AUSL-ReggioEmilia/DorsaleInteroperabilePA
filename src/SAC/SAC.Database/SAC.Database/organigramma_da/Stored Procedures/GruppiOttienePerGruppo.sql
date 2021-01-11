

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Modify date: 2016-11-25 Aggiunto campo Attivo
-- Description:	Ritorna il gruppi di AD per account name
-- =============================================
CREATE PROC [organigramma_da].[GruppiOttienePerGruppo]
(
 @Gruppo varchar(128)
)
AS
BEGIN
	SET NOCOUNT OFF
	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[GruppiOttienePerGruppo]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[GruppiOttienePerGruppo]!', 16, 1)
		RETURN
	END

	--Eseguo query  
	SELECT
		[Id],
		[Gruppo],
		[Descrizione],
		[Attivo]
	FROM [organigramma_da].[Gruppi]
	WHERE Gruppo = @Gruppo
END


