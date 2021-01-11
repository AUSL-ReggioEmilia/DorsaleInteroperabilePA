

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-03-29
-- Description:	Ritorna lista dei SE abilitati per RUOLO
--				letta dal SAC
-- =============================================
CREATE FUNCTION [dbo].[OttieniSacSistemiErogantiPerRuolo]
(
 @CodiceRuolo VARCHAR(16)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT [SistemaCodice] AS SistemaErogante
			,[SistemaAzienda] AS AziendaErogante
	  FROM [dbo].[SAC_RuoliSistemi]
	  WHERE [RuoloCodice] = @CodiceRuolo
)