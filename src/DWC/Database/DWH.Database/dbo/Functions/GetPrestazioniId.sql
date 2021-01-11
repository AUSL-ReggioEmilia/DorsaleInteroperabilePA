


-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	
-- Modify date: 2018-06-08 - ETTORE - Uso della funzione dbo.GetRefertiPK() al posto della dbo.GetRefertiId()
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- =============================================
CREATE FUNCTION [dbo].[GetPrestazioniId] (@IdEsternoRefero AS varchar(64), @IdEsterno AS varchar(64))  
RETURNS uniqueidentifier AS  
BEGIN 

DECLARE @IdReferto AS uniqueidentifier
DECLARE @Ret AS uniqueidentifier

	SELECT @IdReferto = ID 
		FROM [dbo].[GetRefertiPk](RTRIM(@IdEsternoRefero))

	SELECT @Ret = ID
	FROM store.PrestazioniBase WITH(NOLOCK)
	WHERE IdRefertiBase = @IdReferto AND IDEsterno = RTRIM(@IdEsterno)

	RETURN @Ret

END

