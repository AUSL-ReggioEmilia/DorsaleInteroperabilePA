
CREATE FUNCTION [dbo].[GetAllegatiAttributo]
 (@IdAllegatiBase AS uniqueidentifier, @DataPartizione AS SMALLDATETIME, @Nome AS VARCHAR(64))  
RETURNS SQL_VARIANT AS  
BEGIN
/*
 Ritorna l'ATTRIBUTO in tipo generico

 MODIFICA SANDRO 2015-08-19: Usa le VIEW store
*/
DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore
	FROM store.AllegatiAttributi WITH(NOLOCK) 
 	WHERE IdAllegatiBase = @IdAllegatiBase 
 		AND DataPartizione = @DataPartizione
 		AND Nome = @Nome
	
	RETURN @Ret
END
