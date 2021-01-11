

-- =============================================
-- Author:      Alessandro Nostini
-- Create date: 2017-09-06
-- Modify date: 
-- Description: Ottiene la lista concatenata in string dei codici di oscuramento di tutti
--  gli oscuramenti a cui l'evento è soggetto
-- =============================================

CREATE FUNCTION [dbo].[GetEventoOscuramentiString]
(
	@AziendaErogante varchar(16),
	@NumeroNosologico varchar(64)
)
RETURNS VARCHAR(8000)
AS
BEGIN

	DECLARE @StrRet VARCHAR(8000) = ''

	SELECT @StrRet = @StrRet + CAST(CodiceOscuramento AS VARCHAR) +  ','
	FROM (
		SELECT DISTINCT o.CodiceOscuramento
		FROM dbo.GetEventoOscuramenti(@AziendaErogante, @NumeroNosologico) AS o 
		) oscuramenti

	IF @StrRet = ''	
		SET @StrRet = NULL	 
	ELSE 		
		SET @StrRet = LEFT(@StrRet, LEN(@StrRet)-1)

	RETURN @StrRet
END