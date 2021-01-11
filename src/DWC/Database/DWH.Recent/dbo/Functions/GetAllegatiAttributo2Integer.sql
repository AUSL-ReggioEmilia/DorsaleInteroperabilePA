﻿

CREATE FUNCTION [dbo].[GetAllegatiAttributo2Integer]
	(@IdAllegatiBase AS UNIQUEIDENTIFIER
	 ,@DataPartizione SMALLDATETIME
	 ,@Nome AS VARCHAR(64))  
RETURNS INTEGER AS  
BEGIN 
/*
	Ritorna l'attributo tipizzato INTEGER
	CREATA SANDRO: 2015-05-13 
*/
DECLARE @Ret AS INTEGER 
DECLARE @Valore AS SQL_VARIANT

	SELECT @Valore = Valore
	FROM AllegatiAttributi WITH(NOLOCK)
 	WHERE IdAllegatiBase = @IdAllegatiBase 
 		AND DataPartizione = @DataPartizione
 		AND Nome = @Nome	

	IF ISNUMERIC(CONVERT(VARCHAR(40), @Valore)) = 1
		SET @Ret = CAST( @Valore AS INTEGER)
	ELSE
		SET @Ret = NULL
		
	RETURN @Ret
END

