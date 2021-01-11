
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2018-08-21 sandro - Invalida la cache dell'utente
-- Modify date: 2019-03-12 sandro - Time in minuti default 60
--
-- Description:	Modifica la membership di un gruppo
-- =============================================
CREATE PROCEDURE [dbo].[Maintenance_CacheGruppiUtente]
(
@MinuteOld INT = 60
)
AS
BEGIN
	SET NOCOUNT ON
	--
	-- Cancella cache di oggetti vecchi
	--
	UPDATE [dbo].[UtentiGruppiDominio]
		SET CacheGruppiUtente = NULL
		WHERE [DataModifica] < DATEADD(MINUTE, @MinuteOld * -1, GETUTCDATE())
			AND NOT CacheGruppiUtente IS NULL
END