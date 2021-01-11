
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-04-04
-- Description:	Configurazione del DOMINIO sorgente
-- =============================================
CREATE FUNCTION [dbo].[ConfigAdDomainName]()
RETURNS varchar(1024)
AS
BEGIN

DECLARE @RetValue varchar(1024)

	SELECT @RetValue = [Valore]
	FROM [dbo].[Configurazione]
	WHERE [Nome] = 'AdDomainName' 

	RETURN @RetValue
END

