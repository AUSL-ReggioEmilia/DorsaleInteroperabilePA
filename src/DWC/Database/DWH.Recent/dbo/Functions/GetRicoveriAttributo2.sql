

CREATE FUNCTION [dbo].[GetRicoveriAttributo2]
	(@IdRicoveriBase AS UNIQUEIDENTIFIER
	,@DataPartizione AS SMALLDATETIME
	,@Nome AS VARCHAR(32))  
RETURNS SQL_VARIANT AS  
BEGIN 
/*
	Ritorna l'attributo non tipizzato
	CREATA SANDRO: 2015-05-13 
*/
DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore 
	FROM RicoveriAttributi WITH(NOLOCK) 
	WHERE IdRicoveriBase = @IdRicoveriBase
		AND DataPartizione = @DataPartizione 
		AND Nome = @Nome
	RETURN @Ret

END

