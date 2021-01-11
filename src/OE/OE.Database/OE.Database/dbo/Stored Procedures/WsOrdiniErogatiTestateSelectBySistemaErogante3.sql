
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2012-03-07
-- Description:	Seleziona una testata ordine erogato by idrichiestaerogante + sistema erogante
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniErogatiTestateSelectBySistemaErogante3]
	  @IDSistemaErogante uniqueidentifier
	, @IDRichiestaErogante varchar(64)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT *
	FROM [WsOrdiniErogatiTestateSelect] TE
	WHERE TE.IDSistemaErogante = @IDSistemaErogante
		AND TE.IDRichiestaErogante = @IDRichiestaErogante
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniErogatiTestateSelectBySistemaErogante3] TO [DataAccessWs]
    AS [dbo];

