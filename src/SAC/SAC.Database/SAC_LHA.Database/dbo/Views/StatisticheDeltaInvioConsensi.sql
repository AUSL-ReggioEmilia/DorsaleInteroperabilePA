
CREATE VIEW [dbo].[StatisticheDeltaInvioConsensi]
AS
SELECT COUNT(*) AS Numero
	,CONVERT(DATE, [DataElaborazione]) AS DataInvio
  FROM [dbo].[ConsensiDropTable] WITH(NOLOCK)
  GROUP BY CONVERT(DATE, [DataElaborazione])


GO
GRANT SELECT
    ON OBJECT::[dbo].[StatisticheDeltaInvioConsensi] TO [Execute Viewer]
    AS [dbo];

