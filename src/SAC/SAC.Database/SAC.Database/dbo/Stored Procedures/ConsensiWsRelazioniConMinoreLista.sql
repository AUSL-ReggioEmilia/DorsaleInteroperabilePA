-- =============================================
-- Author:		Ettore
-- Create date: 2016-01-12
-- Description:	Restituisce le possibili relazioni con il minore
-- =============================================
CREATE PROCEDURE [dbo].[ConsensiWsRelazioniConMinoreLista]
(
	@Identity varchar(64)
)
AS
BEGIN
	SET NOCOUNT ON;
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	IF dbo.LeggeConsensiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC ConsensiEventiAccessoNegato @Identity, 0, 'ConsensiWsRelazioniConMinoreLista', 'Utente non ha i permessi di lettura!'
		RAISERROR('Errore di controllo accessi durante ConsensiWsRelazioniConMinoreLista!', 16, 1)
		RETURN
	END
	
	SELECT 
		Id
		, Descrizione
	FROM 
		RelazioneConMinore
	ORDER BY 
		Ordinamento
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiWsRelazioniConMinoreLista] TO [DataAccessWs]
    AS [dbo];

