
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SetLogLhaTipoFullsync]
	@BatchSize AS INT = 1000
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[Log]
	SET DaFullSync = 1
	WHERE [Id] IN (
			   
	SELECT TOP (@BatchSize)
				l.[Id]
	  FROM [dbo].[Log] l WITH(NOLOCK) INNER JOIN dbo.PazientiDropTable dt WITH(NOLOCK) 
		ON l.IdLHA = dt.IdLha
	WHERE (l.[DataLog] BETWEEN dt.[DataInvio] AND DATEADD(minute, 5, dt.[DataInvio]))
		AND (l.DaFullSync IS NULL OR l.DaFullSync = 0)
	ORDER BY l.[Id]
	
					)

END

