
CREATE PROCEDURE [dbo].[MaintenanceStorico]
(
 @DEBUG BIT = 0
,@LOG BIT = 0
)
AS
BEGIN
-- Modifiche:
-- 2013-01-23 Sandro: Primo rilascio 
-- 2014-11-19 Sandro: Usa le nuove SP che usano la nuova funct con EXISTS invece che COUNT 
-- 2014-11-24 Sandro: Di notte archivia i passati e senza risposta 
-- 2015-01-27 Sandro: Modifiche alle date
-- 2019-04-08 Sandro: Storico CodaRichiesteInviate
-- 2019-12-04 Sandro: Dimezzato il batch e dimezzato il tempo di schedulazione a 30 min
-- 2020-04-28 Sandro: Rimossp comando compressione, e compressione durante l'archiviazione

	SET NOCOUNT ON

	-- Valori di Archiviazione al 2020-04-21
	--
	-- GiorniOrdiniCompletati = 30
	-- GiorniOrdiniPrenotazioniPassate = 120
	-- GiorniOrdiniNoRisposta = 120
	-- GiorniOrdiniAltro = 180
	-- GiorniVersioniCompletati = 1
	-- GiorniVersioniPrenotazioniPassate = 7

	-- Archiviazione dati

	EXEC [dbo].[MaintenanceStorico_Ordine_Completati] 2500, @DEBUG, @LOG
	EXEC [dbo].[MaintenanceStorico_Ordine_PrenotazionePassata] 1000, @DEBUG, @LOG
		
	-- Di notte
	--
	DECLARE @OraCorrente INT = DATEPART(HOUR, GETDATE())
	IF @OraCorrente > 20 OR @OraCorrente < 7
	BEGIN
		EXEC [dbo].[MaintenanceStorico_Ordine_NoRisposta] 1000, @DEBUG, @LOG
		EXEC [dbo].[MaintenanceStorico_Ordine_Rimasti] 1000, @DEBUG, @LOG
	END

	-- Archiviazione dati versioni

	EXEC [dbo].[MaintenanceStorico_Versioni_Completati] 5000, @DEBUG, @LOG
	EXEC [dbo].[MaintenanceStorico_Versioni_PrenotazionePassata] 5000, @DEBUG, @LOG

	-- Archiviazione CodaRichiesteInviate

	EXEC [dbo].[MaintenanceStorico_CodaRichiesteInviate] 2, 1000, @DEBUG, @LOG 

	--Dati dele tabelle di base (stati, sistemi, prestazioni)

	EXEC [dbo].[MaintenanceStorico_TabelleDiBase]

	IF @DEBUG = 0
	BEGIN
		-- Cancella messaggi orfani

		EXEC [dbo].[MaintenanceCancella_MessaggiRichiesteOrfani] 5, 500
		EXEC [dbo].[MaintenanceCancella_MessaggiStatiOrfani] 5, 1000

		-- Cancella ticket

		EXEC [dbo].[MaintenanceCancella_Ticket]

	END

END
