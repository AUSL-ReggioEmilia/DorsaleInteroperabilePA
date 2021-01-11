



-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2018-09-14
-- Description:	Configurazione del filtro utenti
-- =============================================
CREATE FUNCTION [dbo].[ConfigFilterUser]()
RETURNS varchar(1024)
AS
BEGIN
	DECLARE @RetValue varchar(1024) = NULL

	SELECT @RetValue = [Valore]
	FROM [dbo].[Configurazione]
	WHERE [Nome] = 'FilterUser' 

	RETURN @RetValue
END

