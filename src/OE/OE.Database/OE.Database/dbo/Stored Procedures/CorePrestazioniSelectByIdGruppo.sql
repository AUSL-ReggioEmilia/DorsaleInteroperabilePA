
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-02-18
-- Description:	Seleziona la prestazione per gruppo prestazione
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniSelectByIdGruppo]
	  @IdGruppo UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT  P.*		
	FROM CorePrestazioniSelect P
		INNER JOIN [dbo].[PrestazioniGruppiPrestazioni] PGP
			ON PGP.IDPrestazione = P.ID
	WHERE PGP.IDGruppoPrestazioni = @IdGruppo
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectByIdGruppo] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectByIdGruppo] TO [DataAccessWs]
    AS [dbo];

