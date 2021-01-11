





-- =============================================
-- Author:		Ettore
-- Description:	Restituisce una lista concatenata di codici di oscuramento relativi al referto passato
-- Create date: 2015-07-10
-- Modify date: 2016-10-14 Stefano P.: Aggiunto filtro ApplicaDWH
-- Modify date: 2017-04-07 Ettore: Adeguamento per gestire sistemi eroganti di ricoveri diversi da ADT
-- Modify date: 2017-11-03 Ettore: Utilizzato le nuove table function degli oscuramenti
-- =============================================
CREATE FUNCTION [dbo].[GetRefertoCodiciOscuramento2]
(
 @IdReferto UNIQUEIDENTIFIER,
 @IdEsternoReferto VARCHAR(64),
 @DataPartizione SMALLDATETIME, 
 @AziendaErogante varchar(16),
 @SistemaErogante varchar(16),
 @StrutturaEroganteCodice varchar(64), 
 @NumeroNosologico varchar(64),
 @RepartoRichiedenteCodice varchar(16),
 @RepartoErogante varchar(64), 
 @NumeroPrenotazione varchar(32),
 @NumeroReferto varchar(16),
 @IdOrderEntry varchar(64),
 @Confidenziale BIT
 )  
RETURNS VARCHAR(1000)
AS
BEGIN
	DECLARE @StrRet VARCHAR(1000) = ''
	
	
	-- PULIZIA DELLE STRINGHE VUOTE
	SET @AziendaErogante = NULLIF(@AziendaErogante, '')
	SET @SistemaErogante= NULLIF(@SistemaErogante, '')
	SET @NumeroNosologico = NULLIF(@NumeroNosologico , '')
	SET @RepartoRichiedenteCodice = NULLIF(@RepartoRichiedenteCodice , '')
	SET @NumeroPrenotazione = NULLIF(@NumeroPrenotazione , '')
	SET @NumeroReferto= NULLIF(@NumeroReferto, '')
	SET @IdOrderEntry = NULLIF(@IdOrderEntry , '') 
	SET @RepartoErogante = NULLIF(@RepartoErogante, '')
	SET @StrutturaEroganteCodice = NULLIF(@StrutturaEroganteCodice, '')

	SELECT @StrRet = @StrRet + CAST(CodiceOscuramento AS VARCHAR) +  ','
	FROM [dbo].[OttieniRefertoOscuramenti] (
									NULL
									, 'Massivi'
									, 'DWH'
									, @IdEsternoReferto
									, @IdReferto
									, @DataPartizione
									, @AziendaErogante
									, @SistemaErogante
									, @NumeroNosologico
									, @NumeroPrenotazione
									, @NumeroReferto
									, @IdOrderEntry
									, @StrutturaEroganteCodice
									, @RepartoRichiedenteCodice
									, @RepartoErogante
									, @Confidenziale
									)
	
	SELECT @StrRet = @StrRet + CAST(CodiceOscuramento AS VARCHAR) +  ','
	FROM [dbo].[OttieniRefertoOscuramenti] (
									NULL
									, 'Puntuali'
									, 'DWH'
									, @IdEsternoReferto
									, @IdReferto
									, @DataPartizione
									, @AziendaErogante
									, @SistemaErogante
									, @NumeroNosologico
									, @NumeroPrenotazione
									, @NumeroReferto
									, @IdOrderEntry
									, @StrutturaEroganteCodice
									, @RepartoRichiedenteCodice
									, @RepartoErogante
									, @Confidenziale
									)
		
		
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

