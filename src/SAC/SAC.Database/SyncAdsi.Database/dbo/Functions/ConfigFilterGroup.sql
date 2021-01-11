




-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2018-09-14
-- Description:	Configurazione del filtro gruppi
-- =============================================
CREATE FUNCTION [dbo].[ConfigFilterGroup]()
RETURNS varchar(1024)
AS
BEGIN
	DECLARE @RetValue varchar(1024) = NULL

	SELECT @RetValue = [Valore]
	FROM [dbo].[Configurazione]
	WHERE [Nome] = 'FilterGroup' 

	RETURN @RetValue
END

