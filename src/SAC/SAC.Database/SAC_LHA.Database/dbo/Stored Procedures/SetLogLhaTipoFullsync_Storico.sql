-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SetLogLhaTipoFullsync_Storico]
	@BatchSize AS INT = 1000
AS
BEGIN

	UPDATE [dbo].[Log_Storico]
	SET DaFullSync = 1
	WHERE [Id] IN (
			   
	SELECT TOP (@BatchSize)
				l.[Id]
	  FROM [dbo].[Log_Storico] l WITH(NOLOCK) INNER JOIN dbo.PazientiDropTable_Storico dt WITH(NOLOCK) 
		ON l.IdLHA = dt.IdLha
	WHERE (l.[DataLog] BETWEEN dt.[DataInvio] AND DATEADD(minute, 5, dt.[DataInvio]))
		AND (DaFullSync IS NULL OR DaFullSync = 0)
	ORDER BY l.[Id]
	
					)
END

