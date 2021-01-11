
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-03-29
-- Description:	Ritorna lista delle UO per RUOLO
--				letta dal SAC
-- =============================================

CREATE FUNCTION [dbo].[OttieniSacUnitaOperativePerRuolo]
(
 @CodiceRuolo VARCHAR(16)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT [UnitaOperativaCodice]
		  ,[UnitaOperativaAzienda]
	  FROM [dbo].[SAC_RuoliUnitaOperative]
	  WHERE [RuoloCodice]  = @CodiceRuolo
)