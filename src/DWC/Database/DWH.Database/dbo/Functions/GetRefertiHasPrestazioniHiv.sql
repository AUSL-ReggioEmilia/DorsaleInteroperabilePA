

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetRefertiHasPrestazioniHiv] (
	 @IdReferto AS uniqueidentifier
	,@DataPartizione as smalldatetime
	)  
RETURNS bit AS  
BEGIN 
	--
	-- Modifica Ettore 2012-11-29: utilizzato EXISTS invece di COUNT() per migliorare le prestazioni
	--
	DECLARE @Ret AS bit
	DECLARE @CountHiv as int
	
	SET @Ret = 0 -- inizializzo
	IF EXISTS( SELECT * FROM store.PrestazioniBase AS PrestazioniBase WITH(NOLOCK) 
			WHERE PrestazioniBase.IdRefertiBase = @IdReferto
			AND PrestazioniBase.DataPartizione = @DataPartizione
			AND (PrestazioniBase.PrestazioneDescrizione LIKE '%HIV%'
				OR PrestazioniBase.SezioneDescrizione LIKE '%HIV%') )
	BEGIN
		SET @Ret = 1  -- Contiene HIV
	END
	--
	--
	--
	RETURN @Ret
END

