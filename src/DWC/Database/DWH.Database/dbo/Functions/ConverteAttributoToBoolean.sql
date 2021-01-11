-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-02-05
-- Description:	Converte un ATTRIBUTO in BIT
-- =============================================
CREATE FUNCTION [dbo].[ConverteAttributoToBoolean] 
(
	@valore sql_variant
)
RETURNS [bit]
AS
BEGIN

	RETURN CONVERT(BIT, 
					CASE ISNULL( UPPER( CONVERT(VARCHAR(16), @valore) ), '')
					WHEN '1' THEN 1 WHEN 'SI' THEN 1 WHEN 'TRUE' THEN 1
					WHEN 'S' THEN 1 WHEN 'T' THEN 1
					WHEN '0' THEN 0 WHEN 'NO' THEN 0 WHEN 'FALSE' THEN 0
					WHEN 'N' THEN 0 WHEN 'F' THEN 0
					WHEN '' THEN 0
					ELSE 0 END)

END