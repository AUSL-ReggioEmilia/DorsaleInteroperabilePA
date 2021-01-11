-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-18
-- Description:	Calcola nome attributi persistenti associati alla visualizzazione di un referto 
--				@Utente OBBLIGATORIO
--				@Versione può essere NULL
-- =============================================
CREATE FUNCTION dbo.NomeAttributoPersistenteVisionato
(
@Utente VARCHAR(64) 
, @Versione INT 
)
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @NomeAttributo VARCHAR(64) = ''
	--
	-- Se @Utente è valorizzato
	-- 
	IF ISNULL(@Utente , '') <> ''
	BEGIN
		DECLARE @BinaryValue varbinary(64)

		SET @NomeAttributo = '$@Visualizzazioni@'

		IF LEN(@Utente) > 40
		BEGIN
			--Scrivo @Utente come HASH ESADECIMALE
			SET @BinaryValue = HASHBYTES('SHA1', @Utente)
			SET @Utente = CONVERT(varchar(40), @BinaryValue, 2) 
		END 
		--
		-- Compongo il nome dell'attributo come prefisso dell'atributo + @Utente (con hash o in chiaro)
		--
		SET @NomeAttributo = @NomeAttributo + @Utente

		IF NOT @Versione IS NULL
		BEGIN 
			--
			-- Compongo il nome dell'attributo aggiungendo la versione
			-- Se la versione è maggiore di 99999 il dato restotuito dalla function avrà come versione max 99999
			--
			SET @NomeAttributo = @NomeAttributo + '@' + CAST(@Versione AS VARCHAR(10))
		END

	END
	-- 
	--
	--
	RETURN @NomeAttributo 

END