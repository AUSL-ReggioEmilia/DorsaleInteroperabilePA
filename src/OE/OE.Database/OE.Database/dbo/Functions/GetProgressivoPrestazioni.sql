

CREATE FUNCTION [dbo].[GetProgressivoPrestazioni]
( 
	@tipoAdmin BIT
)
RETURNS VARCHAR(16)
AS
BEGIN

	DECLARE @lastCode varchar(16)
	DECLARE @prefix varchar(6)

	-- Leggo l'ultimo da DB
	IF @tipoAdmin = 1
	BEGIN
		SELECT TOP 1 @lastCode = SUBSTRING(Codice, 4, 10) 
			FROM Prestazioni
			WHERE Tipo in (1,2) AND Codice LIKE 'ADM%'
			ORDER BY Codice DESC
		
		SET @prefix = 'ADM'
	END
	ELSE
	BEGIN
		SELECT TOP 1 @lastCode = SUBSTRING(Codice, 4, 10)
			FROM Prestazioni
			WHERE Tipo = 3 AND Codice LIKE 'USR%'
			ORDER BY Codice DESC
		
		SET @prefix = 'USR'
	END
	
	-- Incremento il numero
	DECLARE @progressivo INT = 1
	DECLARE @newCode AS VARCHAR(16)

	IF ISNUMERIC(@lastCode) = 1
		BEGIN
			SELECT @progressivo = CAST(@lastCode AS INT) + 1
		END
		
	SET @newCode = RIGHT('0000000000' + CAST(@progressivo AS VARCHAR(10)), 7)
	
	RETURN @prefix + @newCode
END
