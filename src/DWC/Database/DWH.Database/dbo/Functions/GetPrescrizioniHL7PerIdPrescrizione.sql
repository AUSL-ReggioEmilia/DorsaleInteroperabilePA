-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-11-03
-- Description:	Ritorna i dati letti dall'allegato XML
-- =============================================
CREATE FUNCTION [dbo].[GetPrescrizioniHL7PerIdPrescrizione]
(
 @IdPrescrizioniBase AS UNIQUEIDENTIFIER
,@DataPartizione AS SMALLDATETIME
,@TipoPrescrizione AS VARCHAR(16)
)
RETURNS @Ret TABLE (
	 Testata XML
	,Righe XML
	)
AS
BEGIN

DECLARE @XmlFile AS XML
		
	SELECT @XmlFile = CONVERT(XML, dbo.decompress(ContenutoCompresso))
	FROM [store].[PrescrizioniAllegatiBase]
	WHERE [IdPrescrizioniBase] = @IdPrescrizioniBase
	AND [DataPartizione] = @DataPartizione
		AND [TipoContenuto] = 'text/xml'

	IF @TipoPrescrizione = 'Specialistica'
	BEGIN
		INSERT @Ret
		SELECT CONVERT(XML, (SELECT * 
							FROM [dbo].[GetPrescrizioniHL7Testata](@XmlFile) AS Testata
							FOR XML AUTO, ELEMENTS)
							) AS Testata
			 , CONVERT(XML, (SELECT * 
							FROM [dbo].[GetPrescrizioniHL7Specialistica](@XmlFile) AS Riga
							FOR XML AUTO, ELEMENTS, ROOT('Righe'))
							) AS Righe

	END IF @TipoPrescrizione = 'Farmaceutica'
	BEGIN

		INSERT @Ret
		SELECT CONVERT(XML, (SELECT * 
							FROM [dbo].[GetPrescrizioniHL7Testata](@XmlFile) AS Testata
							FOR XML AUTO, ELEMENTS)
							) AS Testata
			 , CONVERT(XML, (SELECT * 
							FROM [dbo].[GetPrescrizioniHL7Farmaceutica](@XmlFile) AS Riga
							FOR XML AUTO, ELEMENTS, ROOT('Righe'))
							) AS Righe
	END
	
	RETURN
END