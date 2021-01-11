-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-25
-- Description:	Cancella dalle tabelle:
--					RefertiAvvertenzeCodaProcessate  
-- =============================================
CREATE PROCEDURE dbo.MntRefertiAvvertenzePurge
(
@CountBatch INT = 10
,@Top INT = 1000
,@GiorniDaMantenere INT = 60
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @trip INT
	DECLARE @err INT
	DECLARE @row INT
	--
	-- Cancellazione dalla tabella RefertiAvvertenzeCodaProcessate
	--
	PRINT 'Cancellazione dalla RefertiAvvertenzeCodaProcessate' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		DELETE TOP(@Top) FROM RefertiAvvertenzeCodaProcessate
		WHERE DataProcessoUtc < DATEADD(DAY, - @GiorniDaMantenere, GETUTCDATE())

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END


END