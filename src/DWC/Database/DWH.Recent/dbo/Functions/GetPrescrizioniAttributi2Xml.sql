

CREATE FUNCTION [dbo].[GetPrescrizioniAttributi2Xml]
	(@IdPrescrizioniBase AS UNIQUEIDENTIFIER
	,@DataPartizione AS SMALLDATETIME
	)  
RETURNS XML AS  
BEGIN 
/*
	Ritorna XML di tutti gli attributi
	CREATA SANDRO: 2016-08-09
*/
DECLARE @Ret AS XML

	SET @Ret = (SELECT Nome, Valore
					, SQL_VARIANT_PROPERTY(Valore, 'BaseType') AS [BaseType] 
					, SQL_VARIANT_PROPERTY(Valore, 'Precision') AS [Precision]
					, SQL_VARIANT_PROPERTY(Valore, 'Scale') AS [Scale]
				FROM [dbo].[PrescrizioniAttributi] Attributo WITH(NOLOCK)
				WHERE IdPrescrizioniBase = @IdPrescrizioniBase 
					AND DataPartizione = @DataPartizione
				FOR XML AUTO, ROOT('Attributi')
				)				
	RETURN @Ret
END