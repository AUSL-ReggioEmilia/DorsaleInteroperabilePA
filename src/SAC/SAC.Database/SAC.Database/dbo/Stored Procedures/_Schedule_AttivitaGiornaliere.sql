
CREATE PROCEDURE [dbo].[_Schedule_AttivitaGiornaliere] 
AS
BEGIN
/*
Occurs every day every 1 hour(s) between 07:07:00 and 19:07:59.
 Schedule will be used starting on 2/16/2009.
*/
	--Non fa niente
	-- EXEC dbo.MntPazientiBatchDeleteNoCodiceFiscale

	-- Aggancia i consensi a posizioni anagrafiche esistenti
	-- Esecuzione aggiunta il 2010-09-07 alle ore 12:30
	EXEC dbo.ConsensiBatchAggancioPaziente

	-- Merge dei pazienti
	EXEC dbo.PazientiBatchMerge

	--Pulisce notifiche
	EXEC dbo.MntPazientiNotificaArchivia
	EXEC dbo.MntConsensiNotificaArchivia

END



