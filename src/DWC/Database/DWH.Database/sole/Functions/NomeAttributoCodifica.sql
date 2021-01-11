
-- ==================================================================
-- Author:		Alessandro Nostini
-- Create date: 2018-01-26
-- Description:	Converte il nome di un  attributo in un nome valido
--				 per un Elemento Xml
--
-- ==================================================================
CREATE FUNCTION [sole].[NomeAttributoCodifica]
(
	@Name VARCHAR(128)
)
RETURNS VARCHAR(128)
AS
BEGIN
	DECLARE @Ret VARCHAR(128) = @Name
	--
	-- Sostituisco caratteri non validi
	--
	SET @Ret = REPLACE(@Ret, '(', '_28')
	SET @Ret = REPLACE(@Ret, ')', '_29')
	SET @Ret = REPLACE(@Ret, '[', '_5B')
	SET @Ret = REPLACE(@Ret, ']', '_5D')
	SET @Ret = REPLACE(@Ret, '{', '_7B')
	SET @Ret = REPLACE(@Ret, '}', '_7D')
	SET @Ret = REPLACE(@Ret, '<', '_3C')
	SET @Ret = REPLACE(@Ret, '>', '_3E')
	SET @Ret = REPLACE(@Ret, '\', '_5C')
	SET @Ret = REPLACE(@Ret, '/', '_2F')
	SET @Ret = REPLACE(@Ret, '!', '_21')
	SET @Ret = REPLACE(@Ret, '?', '_3F')
	SET @Ret = REPLACE(@Ret, '%', '_25')
	SET @Ret = REPLACE(@Ret, '$', '_24')
	SET @Ret = REPLACE(@Ret, '&', '_26')
	SET @Ret = REPLACE(@Ret, '!', '_21')
	SET @Ret = REPLACE(@Ret, '£', '_A3')
	SET @Ret = REPLACE(@Ret, '=', '_3D')
	SET @Ret = REPLACE(@Ret, '^', '_5E')
	SET @Ret = REPLACE(@Ret, '+', '_2B')
	SET @Ret = REPLACE(@Ret, '@', '_40')
	SET @Ret = REPLACE(@Ret, '°', '_B0')
	SET @Ret = REPLACE(@Ret, '#', '_23')
	SET @Ret = REPLACE(@Ret, ';', '_3B')
	SET @Ret = REPLACE(@Ret, ':', '_3A')
	SET @Ret = REPLACE(@Ret, ',', '_2C')
	SET @Ret = REPLACE(@Ret, '*', '_2A')
	SET @Ret = REPLACE(@Ret, '|', '_7C')
	SET @Ret = REPLACE(@Ret, '"', '_22')
	SET @Ret = REPLACE(@Ret, '''', '_27')
	--
	-- Controllo il primo carattere se è una lettera valida
	--
	DECLARE @FirstChr INT = ASCII(LEFT(@Ret, 1))
	IF NOT ((@FirstChr > 64 AND @FirstChr < 91) OR (@FirstChr > 96 AND @FirstChr < 123) OR @FirstChr = 95 )
		SET @Ret = '_' + @Ret

	RETURN @Ret
END