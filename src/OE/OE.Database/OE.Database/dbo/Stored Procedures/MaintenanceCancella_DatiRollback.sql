-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-03-02
-- Description:	Cancella i dati di roolbak inutili
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceCancella_DatiRollback]
AS
BEGIN

	SET NOCOUNT ON
	
	UPDATE TOP(1000) OrdiniTestate
		SET DatiRollback = NULL
	WHERE NOT DatiRollback IS NULL
		AND Data < DATEADD(HOUR, -2, GETDATE())
	
END
