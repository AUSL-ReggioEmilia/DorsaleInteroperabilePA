
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2012-03-07
-- Description:	Seleziona una testata ordine erogato per protocollo richiesta + idsplit
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniErogatiTestateSelectByProtocolloIDSplit3]
	  @Anno int
	, @Numero int
	, @IDSplit tinyint
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT *
	FROM [WsOrdiniErogatiTestateSelect] TE
	WHERE TE.Anno = @Anno
		AND TE.Numero = @Numero
		AND TE.IDSplit = @IDSplit
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniErogatiTestateSelectByProtocolloIDSplit3] TO [DataAccessWs]
    AS [dbo];

