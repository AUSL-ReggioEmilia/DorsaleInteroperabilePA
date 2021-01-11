


-- =============================================
-- Author:		Ettore
-- Create date: 2018-01-22
-- Description:	Restituisce il primo errore ISTAT che si verifica
-- =============================================
CREATE FUNCTION [dbo].[GetErroreIncoerenzaIstat]
(
	@ComuneNascitaCodice AS VARCHAR(6)
	, @ComuneResCodice AS VARCHAR(6)
	, @ComuneDomCodice AS VARCHAR(6)
	, @DataNascita DATETIME 
)
RETURNS INTEGER
AS 
BEGIN
/*
	ATTENZIONE: La funzione si aspetta i codici comune già normalizzati
	ComuneNascitaCodice, ComuneResCodice, ComuneDomCodice sono gli unici codici comune usati nei WS
	
	@DataNascita serve per verificare la coerenza del comune di nascita
	GETDATE() serve per verificare la coerenza del comune di residenza e domicilio

	Codici di errore:
		5000 comune nascita non valido
		5001 comune residenza non valido
		5002 comune domicilio non valido
*/
	DECLARE @Now AS DATETIME 
	DECLARE @ComuneCodiceValido BIT
	SET @ComuneCodiceValido = 1				
	SET @Now = GETDATE()
	--
	-- Verifico il comune di nascita
	--
	SELECT @ComuneCodiceValido = dbo.GetIsValidoCodiceIstatComune (@ComuneNascitaCodice, @DataNascita)
	IF @ComuneCodiceValido = 0
	BEGIN
		--
		-- Impostazione codice di errore
		--
		RETURN 5000 --comune nascita non valido
	END 
	--
	-- Verifico il comune di residenza
	--
	SELECT @ComuneCodiceValido = dbo.GetIsValidoCodiceIstatComune (@ComuneResCodice, @Now)
	IF @ComuneCodiceValido = 0
	BEGIN
		--
		-- Impostazione codice di errore
		--
		RETURN 5001 --comune residenza non valido			
	END 
	--
	-- Verifico il comune di domicilio
	--
	SELECT @ComuneCodiceValido = dbo.GetIsValidoCodiceIstatComune(@ComuneDomCodice, @Now)
	IF @ComuneCodiceValido = 0
	BEGIN
		--
		-- Impostazione codice di errore
		--
		RETURN 5002 --comune domicilio non valido						
	END 
	--
	-- Se sono qui nessun errore
	--
	RETURN 0 --Nessun errore
END