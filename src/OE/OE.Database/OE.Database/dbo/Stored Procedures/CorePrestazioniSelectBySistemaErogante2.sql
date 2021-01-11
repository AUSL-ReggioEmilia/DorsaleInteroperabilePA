
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2011-11-18, eliminato il campo P.IDParametroSpecifico
-- Modify date: 2014-02-17, eliminati campi data e ticket e aggiunto CodiceSinonimo
-- Description:	Seleziona la prestazione per sistema erogante
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniSelectBySistemaErogante2]
	  @Codice varchar(16)
	, @IDSistemaErogante uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  *		
	FROM CorePrestazioniSelect P
	WHERE	P.Codice = @Codice
		AND P.IDSistemaErogante = @IDSistemaErogante
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectBySistemaErogante2] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectBySistemaErogante2] TO [DataAccessWs]
    AS [dbo];

