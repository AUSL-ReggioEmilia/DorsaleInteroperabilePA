





-- =============================================
-- Author:		Simone Bitti
-- Description:	Restituisce una lista concatenata di codici di oscuramento relativi al Ricovero passato
-- Create date: 2017-03-09
-- Modify date: 2017-04-07 Ettore: Adeguamento per gestire sistemi eroganti di ricoveri diversi da ADT
-- Modify date: 2017-11-03 Ettore: Utilizzo delle nuove table function degli oscuramenti
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveroCodiciOscuramento]
(
	@AziendaErogante varchar(16),
	@NumeroNosologico varchar(64)
)  
RETURNS VARCHAR(1000)
AS
BEGIN
	DECLARE @StrRet VARCHAR(1000) = ''
	
	-- PULIZIA DELLE STRINGHE VUOTE
	SET @AziendaErogante = NULLIF(@AziendaErogante, '')
	SET @NumeroNosologico = NULLIF(@NumeroNosologico , '')

	SELECT @StrRet = @StrRet + CAST(CodiceOscuramento AS VARCHAR) +  ','
	FROM [dbo].[OttieniRicoveroOscuramenti] (NULL , 'Massivi', 'DWH', @AziendaErogante, @NumeroNosologico)

	SELECT @StrRet = @StrRet + CAST(CodiceOscuramento AS VARCHAR) +  ','
	FROM [dbo].[OttieniRicoveroOscuramenti] (NULL , 'Puntuali', 'DWH', @AziendaErogante, @NumeroNosologico)
	
	IF @StrRet = ''	
		SET @StrRet = NULL	 
	ELSE 		
	BEGIN
		SET @StrRet = LEFT(@StrRet, LEN(@StrRet)-1) --tolgo separatore finale
		DECLARE @StrRet2 VARCHAR(1000)=''
		SELECT @StrRet2 = @StrRet2 + TAB.String + ',' FROM (
			SELECT DISTINCT String FROM [dbo].[StringSplit](@StrRet, ',', 0)
			) AS TAB
		SET @StrRet = @StrRet2 
		SET @StrRet = LEFT(@StrRet, LEN(@StrRet)-1)		
	END
	--
	--
	--	
	RETURN @StrRet

END