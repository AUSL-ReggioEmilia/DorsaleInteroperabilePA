

-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-06-03
-- Modify date: 
-- Description: Rimuove un'associazione Oscuramento->Ruolo (che può bypassarlo)
-- =============================================
CREATE PROCEDURE [dbo].[BevsOscuramentoRuoliRimuove]
(
 @IdOscuramento uniqueidentifier,
 @IdRuolo uniqueidentifier
)
AS
BEGIN
  
    DELETE FROM 
		dbo.OscuramentoRuoli
	WHERE 
		IdOscuramento = @IdOscuramento
		AND IdRuolo = @IdRuolo

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsOscuramentoRuoliRimuove] TO [ExecuteFrontEnd]
    AS [dbo];

