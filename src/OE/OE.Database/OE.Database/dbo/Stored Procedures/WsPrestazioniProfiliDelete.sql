








-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-05-29
-- Description:	Rimuove tutte le associazioni
-- =============================================
CREATE PROCEDURE [dbo].[WsPrestazioniProfiliDelete]
	@IDPadre uniqueidentifier

AS
BEGIN
	
	SET NOCOUNT ON;

	DELETE FROM PrestazioniProfili WHERE IDPadre = @IDPadre
	
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsPrestazioniProfiliDelete] TO [DataAccessWs]
    AS [dbo];

