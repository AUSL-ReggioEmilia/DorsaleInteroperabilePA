-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-11-03
-- Description:	Ritorna i dati letti dall'allegato XML
-- =============================================
CREATE FUNCTION [dbo].[GetPrescrizioniHL7FarmaceuticaPerIdPrescrizione]
(	
 @IdPrescrizioniBase AS UNIQUEIDENTIFIER
,@DataPartizione AS SMALLDATETIME
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT * 
	FROM [dbo].[GetPrescrizioniHL7Farmaceutica](
				CONVERT(XML, (SELECT dbo.decompress(ContenutoCompresso)
							  FROM [store].[PrescrizioniAllegatiBase]
							  WHERE [IdPrescrizioniBase] = @IdPrescrizioniBase
								AND [DataPartizione] = @DataPartizione
									AND [TipoContenuto] = 'text/xml')
						)
											)
)