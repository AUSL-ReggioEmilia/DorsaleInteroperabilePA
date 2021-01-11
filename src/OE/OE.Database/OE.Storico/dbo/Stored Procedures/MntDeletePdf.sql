-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-02-01
-- Description:	Cancella le etichette PDF dagli attributi
-- =============================================
CREATE PROCEDURE [dbo].[MntDeletePdf]
(
@BatchSize INT = 500000
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	DECLARE @row INT = 1
	DECLARE @err INT = 0

	WHILE @row > 0 AND @err  =0
	BEGIN
		PRINT CONVERT(VARCHAR(64), GETDATE(), 120) + ' DELETING PDF su ' + DB_NAME()

		DELETE TOP(@BatchSize)
		FROM [dbo].[OrdiniErogatiTestateDatiAggiuntivi]
		WHERE [TipoContenuto] = 'PDF'

		SELECT @row = @@ROWCOUNT, @err = @@ERROR

		PRINT CONVERT(VARCHAR(64), GETDATE(), 120) + ' DELETED ' + CONVERT(VARCHAR(10), @row)  + ' PDF su ' + DB_NAME()
		--
		-- Aspetta se LOG pieno
		--
		WHILE NOT EXISTS( SELECT *
					FROM sys.dm_db_log_space_usage
					WHERE used_log_space_in_percent < 60) 
		BEGIN
			WAITFOR DELAY '00:01:00'
			PRINT 'Wait 1 minuto'
		END
	END

END
