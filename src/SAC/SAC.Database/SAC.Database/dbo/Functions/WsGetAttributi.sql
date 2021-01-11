
-- =============================================
-- Author:		ETTORE
-- Create date: 2016-01-18
-- Description:	Restituisce XML Attributi nel formato atteso dai WS
-- =============================================
CREATE FUNCTION [dbo].[WsGetAttributi]
(
	@Attributi XML
)
RETURNS XML
AS
BEGIN
/*
	ATTENZIONE: Nell'istruzione ";WITH XMLNAMESPACES (DEFAULT 'http://sac.org/Types')" il namespace deve essere scritto
	come indicato
*/
	DECLARE @Ret AS XML = NULL
	
	DECLARE @TableAttributi table (Nome varchar(128), Valore varchar(MAX))
	IF @Attributi IS NOT NULL
	BEGIN
		INSERT INTO @TableAttributi (Nome, Valore)
		SELECT	Attributo.Col.value('@Nome','varchar(128)') AS Nome,
				Attributo.Col.value('@Valore','varchar(MAX)') AS Valore
			FROM @Attributi.nodes('Attributi/Attributo') Attributo(Col)
			

		;WITH XMLNAMESPACES (DEFAULT 'http://sac.org/Types')
		SELECT @Ret = (SELECT Nome, Valore
								FROM @TableAttributi Attributo
								FOR XML AUTO , ROOT('Attributi'), ELEMENTS)
	END

	RETURN @Ret
END