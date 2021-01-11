CREATE FUNCTION [dbo].[GetStatoDisattivatoPaziente](
	@Disattivato AS tinyint
	)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(20)
	SELECT @Ret = 
		CASE
			WHEN @Disattivato = 0 THEN 'Attivo'
			WHEN @Disattivato = 1 THEN 'Cancellato'
			WHEN @Disattivato = 2 THEN 'Fuso'
			ELSE ''
		END

	RETURN @Ret
END

