

CREATE FUNCTION [dbo].[GetPrescrizioniAllegatiAttributi2Xml]
	(@IdPrescrizioniAllegatiBase AS UNIQUEIDENTIFIER
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
				FROM [dbo].[PrescrizioniAllegatiAttributi] Attributo WITH(NOLOCK)
				WHERE IdPrescrizioniAllegatiBase = @IdPrescrizioniAllegatiBase 
					AND DataPartizione = @DataPartizione
				FOR XML AUTO, ROOT('Attributi')
				)				
	RETURN @Ret
END