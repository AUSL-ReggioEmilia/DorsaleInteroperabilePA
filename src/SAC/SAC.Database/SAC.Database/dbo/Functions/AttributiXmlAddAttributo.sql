
-- =============================================
-- Author:		Ettore
-- Create date: 2018-09-21
-- Description:	Aggiunge un nodo Attributo. Il parametro @Attributi NON deve essere NULL
-- =============================================
CREATE FUNCTION [dbo].[AttributiXmlAddAttributo]
(
	@Attributi AS XML
	, @Nome AS VARCHAR(128)
	, @Valore AS VARCHAR(MAX)
)
RETURNS XML
AS
BEGIN
	IF (ISNULL(@Nome, '') <> '') AND (ISNULL(@Valore, '') <> '')
	BEGIN
		DECLARE @Attrib AS XML = '<Attributo Nome="' +  @Nome + '" Valore="' + @Valore +'" />'
		SET @Attributi.modify('insert sql:variable("@Attrib") into (/Attributi)[1]')
	END 
	--
	-- Restituisco
	--
	RETURN @Attributi 
END