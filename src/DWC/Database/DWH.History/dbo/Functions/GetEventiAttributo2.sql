

CREATE FUNCTION [dbo].[GetEventiAttributo2]
	(@IdEventiBase AS UNIQUEIDENTIFIER
	,@DataPartizione SMALLDATETIME
	,@Nome AS VARCHAR(64))  
RETURNS SQL_VARIANT AS  
BEGIN 
/*
	Ritorna l'attributo non tipizzato
	CREATA SANDRO: 2015-05-13 
*/
DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore 
	FROM EventiAttributi WITH(NOLOCK) 
	WHERE IdEventiBase = @IdEventiBase
		AND DataPartizione = @DataPartizione 
		AND Nome = @Nome
		
	RETURN @Ret
END

