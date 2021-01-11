



-- =============================================
-- Author:		ETTORE GARULLI
-- Create date: 2018-01-31
-- Description:	Offusca una stringa
-- =============================================
CREATE FUNCTION [_anon].[Offusca]
(
	@Stringa VARCHAR(64)
)
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @SPOSTAMENTO INTEGER = 1
	DECLARE @NuovaStringa VARCHAR(256) = ''
	DECLARE @Carattere AS VARCHAR(1)
	DECLARE @NuovoCarattere AS VARCHAR(1)
	DECLARE @LenStringa INTEGER 
	DECLARE @Index INTEGER = 1

	SET @LenStringa = LEN(@Stringa)
	IF LEFT(@Stringa, 1) <> '$'	--SE il primo carattere <> '$' allora è da offuscare
	BEGIN 
		--Offusco e restituisco la Stringa offuscata
		SET @LenStringa = LEN(@Stringa)
		WHILE @Index <= @LenStringa 
		BEGIN
			SET @Carattere  = SUBSTRING (@Stringa, @Index , 1)  
			SELECT @NuovoCarattere = [_anon].[OffuscaDeoffuscaChar] (@Carattere , @SPOSTAMENTO)
			SET @NuovaStringa = @NuovaStringa + @NuovoCarattere 
			SET @Index = @Index  + 1
		END
		--Aggiungo il carattere '$' per indicare che la stringa è offuscata
		SET @NuovaStringa = '$' + @NuovaStringa
	END 
	ELSE
	BEGIN
		--Restituisco la Stringa in input
		SET @NuovaStringa = @Stringa 
	END 
	--Restituisco 
	RETURN @NuovaStringa 

END