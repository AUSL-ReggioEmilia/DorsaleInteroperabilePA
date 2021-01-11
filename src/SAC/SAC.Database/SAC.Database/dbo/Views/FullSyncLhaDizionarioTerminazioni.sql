

CREATE VIEW [dbo].[FullSyncLhaDizionarioTerminazioni]
AS
	SELECT 
		CodiceEsterno
		, Codice
		, Descrizione
	FROM dbo.TranscodificaCodiceTerminazione
	WHERE Provenienza = 'LHA'
GO
GRANT SELECT
    ON OBJECT::[dbo].[FullSyncLhaDizionarioTerminazioni] TO [DataAccessSISS]
    AS [dbo];

