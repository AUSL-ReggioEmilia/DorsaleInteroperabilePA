
CREATE FUNCTION [dbo].[GetAllegatiAttributoInteger]
 (@IdAllegatiBase AS uniqueidentifier, @DataPartizione smalldatetime, @Nome AS VARCHAR(64))  
RETURNS INTEGER AS  
BEGIN 
/*
 Ritorna l'ATTRIBUTO in tipo INTEGER

 MODIFICA SANDRO 2015-08-19: Usa le VIEW store
*/
DECLARE @Ret AS INTEGER 
DECLARE @Valore AS SQL_VARIANT

	SELECT @Valore = Valore
	FROM store.AllegatiAttributi WITH(NOLOCK)
 	WHERE IdAllegatiBase = @IdAllegatiBase 
 		AND DataPartizione = @DataPartizione
 		AND Nome = @Nome	

	IF ISNUMERIC(CONVERT(VARCHAR(40), @Valore)) = 1
		SET @Ret = CAST( @Valore AS INTEGER)
	ELSE
		SET @Ret = NULL
		
	RETURN @Ret
END
