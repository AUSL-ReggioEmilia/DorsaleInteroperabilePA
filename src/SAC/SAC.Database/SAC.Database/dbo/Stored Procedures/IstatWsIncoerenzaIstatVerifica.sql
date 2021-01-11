-- =============================================
-- Author:		Ettore
-- Create date: 2014-03-20
-- Description:	Verifica la coerenza dei codici istat
--
-- ATTENZIONE: E' stata creata una nuova function 'dbo.GetErroreIncoerenzaIstat()' da usare al posto dei test sui vari comuni.
--		E' stata usata solo nella SP PazientiOutputCercaAggancioPaziente per risolvere problema NESTED EXEC INSERT 
--		quando richiamata dalle manteinance di aggancio del DWH nel caso di creazione del record paziente. 
--		FAREMO LA MODIFICA ALLA PRIMA OCCASIONE ANCHE IN QUESTA SP
--
-- =============================================
CREATE PROCEDURE [dbo].[IstatWsIncoerenzaIstatVerifica]
(
	  @Identity AS varchar(64)
	, @ComuneNascitaCodice AS VARCHAR(6)
	, @ComuneResCodice AS VARCHAR(6)
	, @ComuneDomCodice AS VARCHAR(6)
	, @DataNascita DATETIME 
)
WITH RECOMPILE
AS
BEGIN
/*
	ATTENZIONE: La SP viene chiamata dai WS e si aspetta i codici comune già normalizzati
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

	SET NOCOUNT ON;
	--
	-- Verifico il comune di nascita
	--
	EXEC dbo.IsValidoCodiceIstatComune @ComuneNascitaCodice, @DataNascita, @ComuneCodiceValido OUTPUT
	IF @ComuneCodiceValido = 0
	BEGIN
		--
		-- Impostazione codice di errore
		--
		SELECT 5000 AS ERROR_CODE --comune nascita non valido
		RETURN 1
	END 
	--
	-- Verifico il comune di residenza
	--
	EXEC dbo.IsValidoCodiceIstatComune @ComuneResCodice, @Now, @ComuneCodiceValido OUTPUT
	IF @ComuneCodiceValido = 0
	BEGIN
		--
		-- Impostazione codice di errore
		--
		SELECT 5001 AS ERROR_CODE --comune residenza non valido			
		RETURN 1
	END 
	--
	-- Verifico il comune di domicilio
	--
	EXEC dbo.IsValidoCodiceIstatComune @ComuneDomCodice, @Now, @ComuneCodiceValido OUTPUT
	IF @ComuneCodiceValido = 0
	BEGIN
		--
		-- Impostazione codice di errore
		--
		SELECT 5002 AS ERROR_CODE --comune domicilio non valido						
		RETURN 1
	END 
	--
	-- Se sono qui nessun errore
	--
	SELECT 0 AS ERROR_CODE --Nessun errore
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[IstatWsIncoerenzaIstatVerifica] TO [DataAccessWs]
    AS [dbo];

