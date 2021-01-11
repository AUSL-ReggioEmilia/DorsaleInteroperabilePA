


-- =============================================
-- Author:		Ettore
-- Create date: 2018-09-21
-- Description:	Cancella un attributo per nome. Il parametro @Attributi NON deve essere NULL!
-- =============================================
CREATE FUNCTION [dbo].[AttributiXmlDeleteAttributo]
(
	@Attributi AS XML
	, @Nome AS VARCHAR(128)
)
RETURNS XML
AS
BEGIN
	IF (NOT @Nome IS NULL)
		SET @Attributi.modify('delete (/Attributi/Attributo[@Nome=sql:variable("@Nome")])[1]')
	--
	-- Restituisco
	--
	RETURN @Attributi 

END