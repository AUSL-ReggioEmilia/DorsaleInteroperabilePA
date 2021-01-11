CREATE PROCEDURE [dbo].[_Schedule_AttivitaOrarie] 
AS
BEGIN
/*
Occurs every day every 1 hour(s) between 00:10:00 and 23:59:59.
 Schedule will be used starting on 12/11/2010.
*/
	--
	-- Cancellazioni solo di NOTTE
	--
	DECLARE @Hour INT = DATEPART(HOUR, GETDATE())
	IF @Hour < 7 OR @Hour > 21
	BEGIN
		
		-- Cancellazione dalla Coda Output Inviati
		--
		EXEC [dbo].[MntPuliziaCodeInvio] 6, 1000
	END
END
