


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-04-16
-- Description:	Configurazione della sorgente LDAP
-- =============================================
CREATE FUNCTION [dbo].[ConfigAccountExec]()
RETURNS varchar(1024)
AS
BEGIN
	DECLARE @RetValue varchar(1024) = NULL

	SELECT @RetValue = [Valore]
	FROM [dbo].[Configurazione]
	WHERE [Nome] = 'AccountExec' 

	RETURN @RetValue
END


