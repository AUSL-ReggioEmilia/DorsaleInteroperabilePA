
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2011-11-18, eliminato il campo P.IDParametroSpecifico
-- Modify date: 2014-02-17, eliminati campi data e ticket e aggiunto CodiceSinonimo
-- Description:	Seleziona la prestazione per ID
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniSelectByID2]
	@Id uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  *		
	FROM CorePrestazioniSelect P
	WHERE P.ID = @Id
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectByID2] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectByID2] TO [DataAccessWs]
    AS [dbo];

