

CREATE FUNCTION [dbo].[GetAllegatiAttributo2]
	(@IdAllegatiBase AS UNIQUEIDENTIFIER
	,@DataPartizione AS SMALLDATETIME
	,@Nome AS VARCHAR(64))  
RETURNS SQL_VARIANT AS  
BEGIN 
/*
	Ritorna l'attributo non tipizzato
	CREATA SANDRO: 2015-05-13 
*/
DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore
	FROM AllegatiAttributi WITH(NOLOCK) 
 	WHERE 
 		IdAllegatiBase = @IdAllegatiBase 
 		AND DataPartizione = @DataPartizione
 		AND Nome = @Nome
	
	RETURN @Ret
END

