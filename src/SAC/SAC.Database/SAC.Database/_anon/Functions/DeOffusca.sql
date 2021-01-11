



-- =============================================
-- Author:		ETTORE GARULLI
-- Create date: 2018-01-31
-- Description:	DeOffusca una stringa
-- =============================================
CREATE FUNCTION [_anon].[DeOffusca]
(
	@Stringa VARCHAR(64)
)
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @SPOSTAMENTO INTEGER = -1
	DECLARE @NuovaStringa VARCHAR(256) = ''
	DECLARE @Carattere AS VARCHAR(1)
	DECLARE @NuovoCarattere AS VARCHAR(1)
	DECLARE @LenStringa INTEGER 
	DECLARE @Index INTEGER = 1

	SET @LenStringa = LEN(@Stringa)
	IF LEFT(@Stringa, 1) = '$' --SE il primo carattere = '$' allora è offuscata quindi deoffusco
	BEGIN 
		--Tolgo il carattere di controllo '$'
		SET @Stringa = RIGHT(@Stringa , LEN(@Stringa) - 1)
		SET @LenStringa = LEN(@Stringa)
		WHILE @Index <= @LenStringa 
		BEGIN
			SET @Carattere  = SUBSTRING (@Stringa, @Index , 1)  
			SELECT @NuovoCarattere = [_anon].[OffuscaDeoffuscaChar] (@Carattere , @SPOSTAMENTO)
			SET @NuovaStringa = @NuovaStringa + @NuovoCarattere 
			SET @Index = @Index  + 1
		END
	END 
	ELSE
	BEGIN
		--Restituisco la Stringa in input
		SET @NuovaStringa = @Stringa 
	END 
	--Restituisco 
	RETURN @NuovaStringa 

END