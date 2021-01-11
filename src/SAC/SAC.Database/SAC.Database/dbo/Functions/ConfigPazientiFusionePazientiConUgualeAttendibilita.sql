-- =============================================
-- Author:		Ettore
-- Create date: 2019-01-21
-- Description:	restituisce il valore della configurazione 'FusionePazientiConUgualeAttendibilita'
-- =============================================
CREATE FUNCTION [dbo].[ConfigPazientiFusionePazientiConUgualeAttendibilita]()
RETURNS BIT
AS
BEGIN
	DECLARE @Ret AS BIT
	SELECT @Ret=CONVERT(BIT, ValoreInt) FROM PazientiConfig WHERE Nome='FusionePazientiConUgualeAttendibilita'
	RETURN ISNULL(@Ret, 0)
END