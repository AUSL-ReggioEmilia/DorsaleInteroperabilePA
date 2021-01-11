
-- =============================================
-- Author:		
-- Create date: 
-- Description:	Attività frequenti
-- Modify date: 2018-10-08 - ETTORE: Aggiunto la chiamata per l'associazione paziente relativa alle note anamnestiche
-- =============================================
CREATE PROCEDURE [dbo].[_Schedule_AttivitaFrequente] 
AS
BEGIN
/*
Occurs every day every 5 minuti(s) between 00:00:00 and 23:59:59.
 Schedule will be used starting on 18/04/2010.
*/

-- serve per associare i pazienti agli eventi ADT, in un caso
-- particolare di nuovo paziente. In questo caso arriva prima
-- l’evento del paziente e questa attività “al volo” non viene 
-- fatta durante l’inserimento. 
-- Il timing veloce serve perché questi eventi servono alle sale
-- operatorie.

DECLARE @DaData datetime

	SET @DaData = DATEADD(hour, -1, GETDATE())

	EXEC dbo.MntRefertiAssociaPaziente @DaData
	EXEC dbo.MntEventiRicoveroAssociaPaziente @DaData
	EXEC dbo.MntEventiListaAttesaAssociaPaziente @DaData
	-- Modify date: 2018-10-08 - ETTORE: Aggiunto la chiamata per l'associazione paziente relativa alle note anamnestiche
	EXEC dbo.MntNoteAnamnesticheAssociaPaziente @DaData
	EXEC dbo.MntSyncOrganigramma

END
