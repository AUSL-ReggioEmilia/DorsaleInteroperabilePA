
-- =============================================
-- Author:		Ettore
-- Create date: 2020-10-21
-- Description:	Processa le tabelle: 
--					ara.AnagraficheCercate
--					ara_svc.CodaAnagraficheDaAggiornareProcessati
-- =============================================
CREATE PROCEDURE [ara].[MntPurge]
(
@DayDelete INT = 60			--cancella i record più vecchi di @DayDelete giorni
, @Batch INT = 500			--numero di record da cancellare per ciclo
, @Loop INT = 20			--numero massimo di cicli
)
AS
--
-- Processa lo svuotamento del DB per gli storici
--
BEGIN
	SET NOCOUNT ON

	PRINT 'Parametri di esecuzione:'
	PRINT '  DayDelete = ' + CONVERT(VARCHAR(10), @DayDelete)
	PRINT '  Batch = ' + CONVERT(VARCHAR(10), @Batch)
	PRINT '  Loop = ' + CONVERT(VARCHAR(10), @Loop)
	
	-- ###########################################################################
	-- Cancellazione dei record più vecchi di N giorni da ara.AnagraficheCercate
	-- ###########################################################################
	DECLARE @err INT = 0
	DECLARE @row INT = 1

	PRINT ''
	PRINT 'Eseguo svuotamento tabella ara.AnagraficheCercate:'

	WHILE @Loop > 0 AND @err = 0 AND @row > 0
	BEGIN
		DELETE TOP(@Batch) FROM ara.AnagraficheCercate
		WHERE DataRisposta >= DATEADD(day, - @DayDelete, GETUTCDATE())

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		SET @Loop = @Loop - 1

		PRINT '[ara.AnagraficheCercate] Cancellati ' + CONVERT(VARCHAR(10), @row) + ' record.'
	END

	-- ###########################################################################
	-- Cancella dalla coda (usata dal servizio NT) degli inviati/processati quelli presenti nella tabella degli scartati
	-- ###########################################################################
	SET @err = 0
	SET @row = 1

	WHILE @Loop > 0 AND @err = 0 AND @row > 0
	BEGIN
		DELETE TOP(@Batch) ara_svc.CodaAnagraficheDaAggiornareProcessati
		WHERE EXISTS (
					SELECT * FROM ara_svc.CodaAnagraficheDaAggiornareInputScartati AS S 
					WHERE S.IdSequenza = ara_svc.CodaAnagraficheDaAggiornareProcessati.IdSequenza
					)

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		SET @Loop = @Loop - 1

		PRINT '[ara_svc.CodaAnagraficheDaAggiornareProcessati] Cancellati ' + CONVERT(VARCHAR(10), @row) + ' messaggi già in ara_svc.CodaAnagraficheDaAggiornareInputScartati.'
	END

	-- ###########################################################################
	-- Cancella dalla coda (usata dal servizio NT) degli inviati/processati quelli più vecchi di N giorni
	-- ###########################################################################
	SET @err = 0
	SET @row = 1

	WHILE @Loop > 0 AND @err = 0 AND @row > 0
	BEGIN
		DELETE TOP(@Batch) ara_svc.CodaAnagraficheDaAggiornareProcessati
		WHERE DataProcessoUtc < DATEADD(day, - @DayDelete, GETUTCDATE())

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		SET @Loop = @Loop - 1

		PRINT '[ara_svc.CodaAnagraficheDaAggiornareProcessati] Cancellati ' + CONVERT(VARCHAR(10), @row) + ' record.'
	END

/*
	-- ###########################################################################
	-- Cancella dalla coda (usata dal servizio NT) degli sacrtati quelli più vecchi di N giorni
	-- ###########################################################################
	SET @err = 0
	SET @row = 1

	WHILE @Loop > 0 AND @err = 0 AND @row > 0
	BEGIN
		DELETE TOP(@Batch) ara_svc.CodaAnagraficheDaAggiornareInputScartati
		WHERE DataProcessoUtc < DATEADD(day, - (2*@DayDelete), GETUTCDATE())

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		SET @Loop = @Loop - 1

		PRINT '[ara_svc.CodaAnagraficheDaAggiornareInputScartati] Cancellati ' + CONVERT(VARCHAR(10), @row) + ' record.'
	END
*/


END