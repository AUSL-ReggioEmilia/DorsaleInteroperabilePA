

-- =============================================
-- Author:		
-- Create date: 
-- Modify date: 2018-10-08 - ETTORE: Aggiunto la chiamata per l'associazione paziente relativa alle note anamnestiche
-- Modify date: 2020-12-23 - KYRYLO: Rimossa la pulizia della tabella PazientiFSE (non più esistente)
--
-- Description:	Attività Notturne
-- =============================================
CREATE PROCEDURE [dbo].[_Schedule_AttivitaNotturne] 
AS
BEGIN
/*
Occurs every day at 03:35:00.
 Schedule will be used starting on 12/22/2009.
*/
	DECLARE @AssociaDallaData as DATETIME
	SET @AssociaDallaData = DATEADD(day, -7, GETDATE())

    EXEC dbo.MntRefertiAssociaPaziente @AssociaDallaData
	EXEC dbo.MntEventiRicoveroAssociaPaziente @AssociaDallaData
	EXEC dbo.MntEventiListaAttesaAssociaPaziente @AssociaDallaData
-- Modify date: 2018-10-08 - ETTORE: Aggiunto la chiamata per l'associazione paziente relativa alle note anamnestiche
	EXEC dbo.MntNoteAnamnesticheAssociaPaziente @AssociaDallaData
		
	--
	-- Archivia accessi
	--
	print 'Esecuzione Maintenance TracciaAccessiStoricizza'

	EXEC [dbo].[MntTracciaAccessiStoricizza] NULL, NULL, 1000

	--
	-- Rilascia vecchi token
	--
	print 'Esecuzione Pulizia Token'
	
	EXEC [dbo].[MntPuliziaTokens] @MaxNum = 10000, @TTLHour = 48
	
END
