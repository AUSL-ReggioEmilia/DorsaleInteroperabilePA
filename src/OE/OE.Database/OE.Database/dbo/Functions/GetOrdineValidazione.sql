-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-01-08
-- Description:	Ottiene un bit che indica se l'ordine è valido (StatoValidazione=AA) o meno
-- =============================================
CREATE FUNCTION GetOrdineValidazione
(	
	@Validazione XML
)
RETURNS TABLE 
AS
RETURN 
(
  SELECT 
	CASE 
		WHEN ISNULL(CAST(@Validazione.query('declare namespace s="http://schemas.progel.it/WCF/OE/WsTypes/1.1";/s:StatoValidazioneType/s:Stato/text()') AS VARCHAR(16)), 'AA') = 'AA' THEN 
			CAST(1 AS BIT)
		ELSE 
			CAST(0 AS BIT) 
		END
	AS Validita
)