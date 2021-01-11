

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-03-29
-- Description:	Ritorna lista degli Accessi per RUOLO
--				letta dal SAC
-- =============================================

CREATE FUNCTION [dbo].[OttieniSacRuoliAccessoPerRuolo]
(
 @CodiceRuolo VARCHAR(16)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT [Accesso]
	  FROM [dbo].[SAC_RuoliAccesso]
	  WHERE [RuoloCodice]  = @CodiceRuolo
		AND Accesso LIKE 'ATTRIB@%'
)