
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2012-03-01
-- Modify date: 2014-02-14 Nuova versione usa Vista [WsOrdiniTestateSelect]
-- Description:	Seleziona una testata ordine by id sistema richiedente
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateSelectByIDSistemaErogante4]
	  @IDSistemaErogante uniqueidentifier
	, @IDRichiestaErogante varchar(64)
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT T.*
	FROM [WsOrdiniTestateSelect] T
			INNER JOIN OrdiniErogatiTestate TE ON TE.IDOrdineTestata = T.ID
	WHERE TE.IDSistemaErogante = @IDSistemaErogante
			AND TE.IDRichiestaErogante = @IDRichiestaErogante
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateSelectByIDSistemaErogante4] TO [DataAccessWs]
    AS [dbo];

