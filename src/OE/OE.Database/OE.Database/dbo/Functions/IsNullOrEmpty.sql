




CREATE FUNCTION [dbo].[IsNullOrEmpty](
	@fieldToCheck as varchar(max),
	@otherField  as varchar(max)
)
returns varchar(max)
AS
BEGIN

IF LEN(ISNULL(@fieldToCheck,'')) = 0

	return @otherField
	else
	return @fieldToCheck
  
  
  return @fieldToCheck
END



