

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetRefertiId] (@IdEsterno AS varchar(64))  
RETURNS uniqueidentifier AS  
BEGIN 

	DECLARE @Ret AS uniqueidentifier
	--
	-- Ricerco nella RefertiBase
	--
	SELECT @Ret = ID
	FROM store.RefertiBase WITH(NOLOCK)
	WHERE IDEsterno = RTRIM(@IdEsterno)
	--
	-- Modifica Ettore del 13/04/2012 per gestione delle catene di referti
	-- Ricerco anche nella RefertiBaseRiferimenti
	--
	IF @Ret IS NULL
		SELECT @Ret = IdRefertiBase 
		FROM store.RefertiBaseRiferimenti WITH(NOLOCK) 
		WHERE IDEsterno = RTRIM(@IdEsterno)
	--
	-- Restituisco
	--
	RETURN @Ret

END

