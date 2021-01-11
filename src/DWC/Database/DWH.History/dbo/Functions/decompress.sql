CREATE FUNCTION [dbo].[decompress]
(@compressedBlob VARBINARY (MAX))
RETURNS VARBINARY (MAX)
AS
 EXTERNAL NAME [Progel.SqlCrl.Compression].[Progel.SqlCrl.Compression.UserDefinedFunctions].[decompress]

