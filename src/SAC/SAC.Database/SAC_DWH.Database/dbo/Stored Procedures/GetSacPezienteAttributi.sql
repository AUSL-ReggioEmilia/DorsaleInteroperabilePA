-- =============================================
-- Author:		Sandro
-- Create date: 2012-03-12
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetSacPezienteAttributi]
	@IdSac  UNIQUEIDENTIFIER
AS
BEGIN

	DECLARE @IntDocXml AS INT

	BEGIN TRY
		DECLARE @XmlPazienti AS XML
		SET @XmlPazienti = (SELECT TOP 1 *
							  FROM dbo.[SAC_PazientiOutput2] AS Paziente
							  WHERE Paziente.Id = @IdSac
							  ORDER BY Paziente.DataModifica DESC 
							  FOR XML AUTO, ELEMENTS
							)

		EXEC sp_xml_preparedocument @IntDocXml OUTPUT, @XmlPazienti

		SELECT @IdSac, a.Nome, CONVERT(varchar(8000), b.Valore) AS Valore
		FROM (
			SELECT id, localname AS Nome
			FROM OPENXML (@IntDocXml, '/Paziente', 1)
			WHERE parentid=0
			) a 
		INNER JOIN
			(
			SELECT parentid, [text] AS Valore
			FROM OPENXML (@IntDocXml, '/Paziente', 1)
			WHERE parentid<>0 AND localname='#text'
			) b 
		ON a.id = b.parentid
		
		EXEC sp_xml_removedocument @IntDocXml
	END TRY
	BEGIN CATCH
		EXEC sp_xml_removedocument @IntDocXml
	END CATCH
	
END
