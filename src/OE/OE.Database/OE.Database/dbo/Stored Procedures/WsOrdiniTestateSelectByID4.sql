
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2012-03-01
-- Modify date: 2014-02-14 Nuova versione usa Vista [WsOrdiniTestateSelect]
-- Description:	Seleziona una testata ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateSelectByID4]
	@ID uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT T.*
	FROM [WsOrdiniTestateSelect] T
	WHERE T.ID = @ID	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateSelectByID4] TO [DataAccessWs]
    AS [dbo];

