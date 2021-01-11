
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-09-28
-- Description:	Ritorna un messaggio di errore
-- =============================================
CREATE FUNCTION [dbo].[GetException]()
RETURNS varchar(2560)
AS
BEGIN
	DECLARE @Result varchar(2560)

	SELECT @Result =
		'ErrorNumber: ' + CONVERT(varchar(8), ERROR_NUMBER()) +
		', Severity: ' + CONVERT(varchar(8), ERROR_SEVERITY()) +
		', State: ' + CONVERT(varchar(8), ERROR_STATE()) + 
		', Procedure: ' + ISNULL(ERROR_PROCEDURE(), '-') + 
		', Line: ' + CONVERT(varchar(8), ERROR_LINE()) +
		', Message: ' + ISNULL(ERROR_MESSAGE(), '-')

	RETURN @Result

END
