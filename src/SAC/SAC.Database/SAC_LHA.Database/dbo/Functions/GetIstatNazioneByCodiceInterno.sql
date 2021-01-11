


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-08-17
-- =============================================
CREATE FUNCTION [dbo].[GetIstatNazioneByCodiceInterno]
(
	@Codice NVARCHAR(3)
)
RETURNS VARCHAR(3)
AS
BEGIN
	DECLARE @RetValue VARCHAR(3) = NULL

	IF NOT NULLIF(@Codice, '') IS NULL
		BEGIN
		    SELECT @RetValue = IstatNazione
				FROM DizionariLhaNazioni WITH(NOLOCK)				
				WHERE CodiceInternoNazione = @Codice
		END
	--
	--
	--
	RETURN @RetValue
END
