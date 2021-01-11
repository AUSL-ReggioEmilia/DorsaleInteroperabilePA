CREATE FUNCTION [dbo].[GetPazienteIdByProvenienza](
	@Provenienza AS varchar(16)
  , @IdProvenienza AS varchar(64)
	)
RETURNS uniqueidentifier
AS
BEGIN
	DECLARE @Ret AS uniqueidentifier

	SELECT TOP 1 @Ret = Id
	FROM Pazienti
	WHERE (Provenienza = @Provenienza)
		AND (IdProvenienza = @IdProvenienza)
	ORDER BY 
		CASE
			WHEN Disattivato = 0 THEN 0
			WHEN Disattivato = 2 THEN 1
			WHEN Disattivato = 1 THEN 2
		END, DataModifica DESC

	RETURN @Ret
END

