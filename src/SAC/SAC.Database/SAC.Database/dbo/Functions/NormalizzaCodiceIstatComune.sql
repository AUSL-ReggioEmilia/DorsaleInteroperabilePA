-- =============================================
-- Author:		Ettore
-- Create date: 2014-03-12
-- Description:	Padding di zeri per avere 6 caratteri + rimozione '999' a sinistra
-- =============================================
CREATE FUNCTION [dbo].[NormalizzaCodiceIstatComune]
(
	@CodiceIstat VARCHAR(6)
)
RETURNS VARCHAR(6)
AS
BEGIN
	DECLARE @RetCodiceIstat VARCHAR(6)
	--
	-- Inizializzo
	--
	SET @RetCodiceIstat = @CodiceIstat 
	--
	-- Padding di '0' per avere sempre 6 caratteri 
	--
	SET @RetCodiceIstat = RIGHT('000000' + @RetCodiceIstat,6) 
	--
	-- Se i primi tre caratteri a sinistra sono '999' li sostituisco con '000'
	--
	IF LEFT(@RetCodiceIstat,3) = '999' 
	BEGIN
		SET @RetCodiceIstat = RIGHT('000000' + RIGHT(@RetCodiceIstat,3) ,6) 
	END
	-- 
	--
	--
	RETURN @RetCodiceIstat

END
