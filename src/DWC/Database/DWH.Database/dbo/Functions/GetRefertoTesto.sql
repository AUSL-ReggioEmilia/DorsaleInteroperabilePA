

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetRefertoTesto] (@IdRefertiBase AS uniqueidentifier, @DataPartizione as smalldatetime)  
RETURNS VARCHAR(MAX) AS  
BEGIN 
--
-- 2012-03-01
-- Sandro
-- Ritorna il testo concatenato della refertazione del medico
--	letta da vari attributi
--
DECLARE @Ret AS VARCHAR(MAX) = ''

	SELECT @Ret = @Ret + CONVERT(VARCHAR(MAX), Valore) + CHAR(13) + CHAR(10) 
	FROM store.RefertiAttributi WITH(NOLOCK)
	WHERE IdRefertiBase = @IdRefertiBase
		AND DataPartizione = @DataPartizione
		AND Nome IN ('Referto', 'Diagnosi', 'Esito', 'Responso')
		AND NOT NULLIF(Valore, '') IS NULL
	
	IF LEN(@Ret) > 2
		SET @Ret = SUBSTRING(@Ret, 1, LEN(@Ret)-2)
	
	RETURN NULLIF(@Ret, '')

END
