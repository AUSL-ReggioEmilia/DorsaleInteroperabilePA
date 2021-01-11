
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetPermessoFusioneByLivelloAttendibilita] (
	@LivelloAttendibilita tinyint
)
RETURNS bit
AS
BEGIN

DECLARE @LivelloMassimo tinyint
SET @LivelloMassimo = 90

DECLARE @Ret AS bit
SET @Ret = 0
	
	IF @LivelloAttendibilita < @LivelloMassimo SET @Ret = 1
	RETURN @Ret

END