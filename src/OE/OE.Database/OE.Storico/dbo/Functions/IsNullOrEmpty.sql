
CREATE FUNCTION [dbo].[IsNullOrEmpty](
	@fieldToCheck as varchar(max),
	@otherField  as varchar(max)
)
RETURNS varchar(max)
AS
BEGIN

	DECLARE @Ret varchar(max)

	IF LEN(ISNULL(@fieldToCheck,'')) = 0
		SET @Ret = @otherField
	ELSE
		SET @Ret = @fieldToCheck
  
	RETURN @Ret
END

