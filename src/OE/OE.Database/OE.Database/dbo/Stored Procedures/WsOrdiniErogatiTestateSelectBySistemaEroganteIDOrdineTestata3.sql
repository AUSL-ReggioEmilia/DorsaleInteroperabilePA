
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2012-03-07
-- Description:	Seleziona una testata ordine erogato by idordinetestata + sistema erogante
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniErogatiTestateSelectBySistemaEroganteIDOrdineTestata3]
	  @IDSistemaErogante uniqueidentifier
	, @IDOrdineTestata uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT *
	FROM [WsOrdiniErogatiTestateSelect] TE
	WHERE TE.IDSistemaErogante = @IDSistemaErogante
		AND TE.IDOrdineTestata = @IDOrdineTestata

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniErogatiTestateSelectBySistemaEroganteIDOrdineTestata3] TO [DataAccessWs]
    AS [dbo];

