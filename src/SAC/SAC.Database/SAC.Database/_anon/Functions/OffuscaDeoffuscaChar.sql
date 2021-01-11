



-- =============================================
-- Author:		ETTORE GARULLI
-- Create date: 2018-01-31
-- Description:	Offusca/Deoffusca singolo carattere usando algoritmo di Cesare
--				Offusca:  @Spostamento = N
--				Deoffusca: @Spostamento = -N
-- =============================================
CREATE FUNCTION [_anon].[OffuscaDeoffuscaChar]
(
	@Carattere VARCHAR(1)
	, @Spostamento INTEGER
)
RETURNS VARCHAR(1)
AS
BEGIN
declare @Asci as INTEGER
--Estremi caratteri minuscoli
DECLARE @LCASE_MIN AS INTEGER = 97
DECLARE @LCASE_MAX AS INTEGER = 122
--Estremi caratteri maiuscoli
DECLARE @UCASE_MIN AS INTEGER = 65
DECLARE @UCASE_MAX AS INTEGER = 90

SET @Asci = ASCII(@Carattere) 
IF @LCASE_MIN <= @Asci and @Asci<= @LCASE_MAX 
BEGIN 
	SET @Asci= @Asci + @Spostamento
	IF @Asci > @LCASE_MAX 
	BEGIN
		SET @Asci = @LCASE_MIN + (@Asci- @LCASE_MAX) - 1
	END 
	ELSE
	IF @Asci < @LCASE_MIN 
	BEGIN 
		SET @Asci = @LCASE_MAX - (@LCASE_MIN - @Asci ) - 1
	END 
END
ELSE
IF @UCASE_MIN <= @Asci  and @Asci <= @UCASE_MAX
BEGIN 
	SET @Asci= @Asci + @Spostamento
	IF @Asci > @UCASE_MAX 
	BEGIN
		SET @Asci = @UCASE_MIN + (@Asci- @UCASE_MAX) - 1
	END 
	ELSE
	IF @Asci < @UCASE_MIN
	BEGIN 
		SET @Asci = @UCASE_MAX - (@UCASE_MIN - @Asci ) - 1
	END 
END
--
-- Restituisco il nuovo carattere 
--
RETURN CHAR(@Asci) 
END