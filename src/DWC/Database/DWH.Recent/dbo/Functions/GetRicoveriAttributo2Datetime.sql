﻿

CREATE FUNCTION [dbo].[GetRicoveriAttributo2Datetime]
	(@IdRicoveriBase AS UNIQUEIDENTIFIER
	,@DataPartizione AS SMALLDATETIME
	,@Nome AS VARCHAR(64))  
RETURNS DATETIME AS  
BEGIN 
/*
	Ritorna l'attributo tipizzato DATETIME
	CREATA SANDRO: 2015-05-13 
*/
DECLARE @Ret AS DATETIME
DECLARE @Valore AS SQL_VARIANT

	SELECT @Valore = Valore
	FROM RicoveriAttributi WITH(NOLOCK)
	WHERE IdRicoveriBase = @IdRicoveriBase
		AND DataPartizione = @DataPartizione 
		AND Nome = @Nome
	
	IF ISDATE(CONVERT(VARCHAR(40), @Valore)) = 1
		SET @Ret = CAST( @Valore AS DATETIME)
	ELSE
		SET @Ret = NULL
		
	RETURN @Ret
END

