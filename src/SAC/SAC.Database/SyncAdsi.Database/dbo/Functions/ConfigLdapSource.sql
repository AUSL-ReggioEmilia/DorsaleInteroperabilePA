
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-04-04
-- Description:	Configurazione della sorgente LDAP
-- =============================================
CREATE FUNCTION [dbo].[ConfigLdapSource]()
RETURNS nvarchar(1024)
AS
BEGIN
	DECLARE @RetValue varchar(1024)

	SELECT @RetValue = [Valore]
	FROM [dbo].[Configurazione]
	WHERE [Nome] = 'Ldap' 

	RETURN @RetValue
END

