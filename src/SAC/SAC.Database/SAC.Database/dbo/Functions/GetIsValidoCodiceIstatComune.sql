
-- =============================================
-- Author:		Ettore
-- Create date: 2018-01-22
-- Description:	Restituisce true se il codice ISTAT del comune è coerente rispetto alla data passata
-- =============================================
CREATE FUNCTION [dbo].[GetIsValidoCodiceIstatComune]
(
	@CodiceIstat AS VARCHAR(6)
	, @Data AS DATETIME
)
RETURNS BIT
AS 
BEGIN
/*
		Restituisce true se il codice ISTAT del comune è coerente rispetto alla data passata
		Se il codice ISTAT non è presente nella tabella IstatComuni restituisce TRUE
*/
	DECLARE @Valido BIT 
	DECLARE @Codice VARCHAR(6)
	DECLARE @DataInizioValidita DATETIME
	DECLARE @DataFineValidita DATETIME
	SET @Valido = 1
	IF (NOT @CodiceIstat IS NULL) AND (NOT @Data IS NULL)
	BEGIN
		--
		-- Ricavo l'intervallo temporale di validità del codice del comune/nazione
		--
		SELECT 
			@Codice=Codice
			, @DataInizioValidita=DataInizioValidita 
			, @DataFineValidita=DataFineValidita 
		FROM 
			IstatComuni 
		WHERE 
			Codice = @CodiceIstat
			
		IF NOT @Codice IS NULL --se il codice ISTAT non è presente non posso fare il test, quindi lo considero valido
		BEGIN
			SET @DataInizioValidita = ISNULL(@DataInizioValidita, '1800-01-01')
			SET @DataFineValidita   = ISNULL(@DataFineValidita, GETDATE())
			--
			-- Ne verifico validita
			--
			IF NOT (@Data BETWEEN @DataInizioValidita AND @DataFineValidita)
			BEGIN
				SET @Valido = 0
			END
		END
	END
	--
	--
	--
	RETURN @Valido
END