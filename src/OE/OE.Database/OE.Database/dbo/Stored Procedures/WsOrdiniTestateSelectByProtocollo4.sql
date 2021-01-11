
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2012-03-01
-- Modify date: 2014-02-14 Nuova versione usa Vista [WsOrdiniTestateSelect]
-- Description:	Seleziona una testata ordine by Protocollo
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateSelectByProtocollo4]
	  @Anno int
	, @Numero int
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT T.*
	FROM [WsOrdiniTestateSelect] T			
		WHERE T.Anno = @Anno 
			AND T.Numero = @Numero
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateSelectByProtocollo4] TO [DataAccessWs]
    AS [dbo];

