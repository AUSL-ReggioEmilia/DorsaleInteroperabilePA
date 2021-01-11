
-- =============================================
-- Author:      Alessandro Nostini
-- Create date: 2017-09-05
-- Modify date: 
-- Description: Ottiene la lista concatenata in string dei codici di oscuramento di tutti
--  gli oscuramenti a cui il referto è soggetto
-- =============================================

CREATE FUNCTION [dbo].[GetRefertoOscuramentiString]
(
 @IdReferto uniqueidentifier,
 @DataPartizione smalldatetime,
 @AziendaErogante varchar(16),
 @SistemaErogante varchar(16),
 @StrutturaEroganteCodice varchar(16),
 @NumeroNosologico varchar(64),
 @RepartoRichiedenteCodice varchar(16),
 @RepartoErogante varchar(64),
 @Confidenziale AS BIT
)  
RETURNS VARCHAR(8000)
AS
BEGIN

	DECLARE @StrRet VARCHAR(8000) = ''

	SELECT @StrRet = @StrRet + CAST(CodiceOscuramento AS VARCHAR) +  ','
	FROM (
		SELECT DISTINCT o.CodiceOscuramento
		FROM dbo.GetRefertoOscuramenti(@IdReferto, @DataPartizione, @AziendaErogante
											, @SistemaErogante, @StrutturaEroganteCodice
											, @NumeroNosologico, @RepartoRichiedenteCodice
											, @RepartoErogante, @Confidenziale) AS o
		) oscuramenti

	IF @StrRet = ''	
		SET @StrRet = NULL	 
	ELSE 		
		SET @StrRet = LEFT(@StrRet, LEN(@StrRet)-1)

	RETURN @StrRet
END