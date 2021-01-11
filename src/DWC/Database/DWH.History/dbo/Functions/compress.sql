CREATE FUNCTION [dbo].[compress]
(@blob VARBINARY (MAX))
RETURNS VARBINARY (MAX)
AS
 EXTERNAL NAME [Progel.SqlCrl.Compression].[Progel.SqlCrl.Compression.UserDefinedFunctions].[compress]

