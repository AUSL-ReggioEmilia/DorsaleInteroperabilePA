

-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2012-03-01
-- Modify date: 2014-02-14 Nuova versione usa Vista [WsOrdiniTestateSelect]
-- Description:	Seleziona una testata ordine by id sistema richiedente
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateSelectByIDSistemaRichiedente4]
	  @IDSistemaRichiedente uniqueidentifier
	, @IDRichiestaRichiedente varchar(64)
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT T.*
	FROM [WsOrdiniTestateSelect] T			
	WHERE T.IDSistemaRichiedente = @IDSistemaRichiedente
		AND T.IDRichiestaRichiedente = @IDRichiestaRichiedente
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateSelectByIDSistemaRichiedente4] TO [DataAccessWs]
    AS [dbo];

