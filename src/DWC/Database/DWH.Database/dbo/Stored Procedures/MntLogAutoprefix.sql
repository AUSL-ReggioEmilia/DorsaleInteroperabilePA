



-- =============================================
-- Author:		ETTORE
-- Create date: 2019-03-05
-- Description:	Cancella dalla tabella LogAutoPrefix i record più vecchi di N giorni
-- =============================================
CREATE PROCEDURE [dbo].[MntLogAutoprefix]
(
	 @CountBatch INT = 1
	,@Top INT = 1000
)
AS
BEGIN

DECLARE @trip INT
DECLARE @err INT
DECLARE @row INT

	--
	-- Cancellazione dalla MntLogAutoprefix
	--
	print 'Cancellazione dalla tabella LogAutoPrefix' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		DELETE FROM LogAutoprefix
		WHERE Id IN (SELECT TOP (@Top) Id FROM LogAutoprefix ORDER BY Id ASC)

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END

END