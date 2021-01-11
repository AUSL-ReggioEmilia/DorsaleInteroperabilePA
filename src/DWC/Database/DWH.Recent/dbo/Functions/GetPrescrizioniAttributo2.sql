
CREATE FUNCTION [dbo].[GetPrescrizioniAttributo2]
(
 @IdPrescrizioniBase AS UNIQUEIDENTIFIER
,@DataPartizione AS SMALLDATETIME
,@Nome AS VARCHAR(64)
)
RETURNS SQL_VARIANT AS  
BEGIN 
/*
	Ritorna l'attributo non tipizzato
	CREATA SANDRO: 2016-11-22
*/
DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore
	FROM PrescrizioniAttributi WITH(NOLOCK)
	WHERE IdPrescrizioniBase = @IdPrescrizioniBase
		AND DataPartizione = @DataPartizione
		AND Nome = @Nome
	
	RETURN @Ret
END