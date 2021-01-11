


CREATE FUNCTION [dbo].[GetRicoveriAttributi2Xml]
	(@IdRicoveriBase AS UNIQUEIDENTIFIER
	,@DataPartizione AS SMALLDATETIME
	)  
RETURNS XML AS  
BEGIN 
/*
	Ritorna XML di tutti gli attributi
	CREATA SANDRO: 2015-05-13 
*/
DECLARE @Ret AS XML

	SET @Ret = (SELECT Nome, Valore
					, SQL_VARIANT_PROPERTY(Valore, 'BaseType') AS [BaseType] 
					, SQL_VARIANT_PROPERTY(Valore, 'Precision') AS [Precision]
					, SQL_VARIANT_PROPERTY(Valore, 'Scale') AS [Scale]
				FROM RicoveriAttributi Attributo WITH(NOLOCK) 
				WHERE IdRicoveriBase = @IdRicoveriBase
					AND DataPartizione = @DataPartizione 
				FOR XML AUTO, ROOT('Attributi')
				)				
	RETURN @Ret
END


