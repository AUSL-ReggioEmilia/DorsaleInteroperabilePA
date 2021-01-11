﻿


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-04-16
-- Description:	Configurazione del Attributo Matricola
-- =============================================
CREATE FUNCTION [dbo].[ConfigAttributoMatricola]()
RETURNS varchar(1024)
AS
BEGIN
	DECLARE @RetValue varchar(1024) = NULL

	SELECT @RetValue = [Valore]
	FROM [dbo].[Configurazione]
	WHERE [Nome] = 'AttributoMatricola' 

	RETURN @RetValue
END

