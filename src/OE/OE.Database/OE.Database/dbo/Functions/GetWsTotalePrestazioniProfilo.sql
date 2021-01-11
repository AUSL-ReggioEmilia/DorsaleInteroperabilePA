




-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-05-30
-- Description:	Ritorna il totale delle prestazioni di un profilo
-- =============================================
CREATE FUNCTION [dbo].[GetWsTotalePrestazioniProfilo](
	@IDProfilo uniqueidentifier
)

RETURNS int

AS
BEGIN
	DECLARE @Totale int

	-- Totale Righe Richieste
    SELECT @Totale = COUNT(*) 
		FROM PrestazioniProfili
		WHERE IDPadre = @IDProfilo

	-- Return	
	RETURN @Totale

END





