-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-08-17
-- =============================================
CREATE FUNCTION [dbo].[GetIstatComuneByCodiceInterno]
(
	@Codice NUMERIC(6,0)
)
RETURNS VARCHAR(6)
AS
BEGIN
	DECLARE @RetValue VARCHAR(6) = NULL

	IF NOT NULLIF(@Codice, '') IS NULL
		BEGIN
		    SELECT @RetValue = IstatComune
				FROM DizionariLhaComuni WITH(NOLOCK)
				WHERE CodiceInternoComune = @Codice
		END
	--
	--
	--
	RETURN @RetValue
END
