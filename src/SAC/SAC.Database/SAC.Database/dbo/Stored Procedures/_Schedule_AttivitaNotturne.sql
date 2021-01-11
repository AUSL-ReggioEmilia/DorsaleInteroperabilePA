
CREATE PROCEDURE [dbo].[_Schedule_AttivitaNotturne] 
AS
BEGIN
/*
Occurs every week on Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday at 04:47:00.
Schedule will be used starting on 12/3/2008.
*/
	--Reimporta consensi ultime 24H da GST ASMN

	--2016-09-28 Non più usato
	--UPDATE SacConnGst.dbo.CONSENSO_INFORMATICO
	--SET ULTIMA_DATA = DATEADD(day, -1, GETDATE())
	--WHERE AZIENDA_EROGANTE = 'ASMN'
	-- AND ULTIMA_DATA > DATEADD(day, -1, GETDATE())

	-- Merge dei pazienti

	EXEC dbo.PazientiBatchMerge 1000, 2880

	--Update LivelloAttendibilita LHA

	UPDATE AuslAsmnRe_SAC.dbo.Pazienti
	SET LivelloAttendibilita = 55
	WHERE  Provenienza = 'LHA'
		AND (PosizioneAss = 2)
		AND (LivelloAttendibilita <> 55)

	--	Pulisce il log notifiche
	
	DELETE PazientiNotificheUtenti_Storico
	FROM dbo.PazientiNotifiche_Storico n 
		INNER JOIN dbo.PazientiNotificheUtenti_Storico nu
				ON	n.id = nu.IdPazientiNotifica
	WHERE Data < CAST(DATEADD(day, -180, GetDate()) AS DATE)

	DELETE PazientiNotifiche_Storico
	WHERE Data < CAST(DATEADD(day, -180, GetDate()) AS DATE)
	
	
	DELETE ConsensiNotificheUtenti_Storico
	FROM dbo.ConsensiNotifiche_Storico n 
		INNER JOIN dbo.ConsensiNotificheUtenti_Storico nu
				ON	n.id = nu.IdConsensiNotifica
	WHERE Data < CAST(DATEADD(day, -180, GetDate()) AS DATE)

	DELETE ConsensiNotifiche_Storico
	WHERE Data < CAST(DATEADD(day, -180, GetDate()) AS DATE)
	--
	-- Pulisce Storico delle Queue
	---
	DELETE FROM dbo.PazientiQueue_Storico
	WHERE DataLog < CAST(DATEADD(day, -60, GetDate()) AS DATE)

	DELETE FROM dbo.ConsensiQueue_Storico
	WHERE DataLog < CAST(DATEADD(day, -60, GetDate()) AS DATE)

	--Pulizia incoerenze ISTAT risolte
	EXEC MntPazientiIncoerenzaIstat
END


