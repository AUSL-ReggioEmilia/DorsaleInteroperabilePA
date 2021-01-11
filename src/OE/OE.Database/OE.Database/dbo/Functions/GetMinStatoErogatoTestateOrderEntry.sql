-- =============================================
-- Author:		Marco Bellini
-- Create date: 2012-02-08
-- Modify date: 2014-08-14 SANDRO: riscritta
-- Modify date: 2015-02-13 SANDRO: Tabella var
--									Controlla anche StatoRisposta e ritorna AA AR AR SE (prima era NULL)
--									SE non calcola ritorna NULL (prima era IC)
-- Description:	Ritorna lo stato erogato order entry minimo delle testate erogate
-- =============================================
CREATE FUNCTION [dbo].[GetMinStatoErogatoTestateOrderEntry]
(
	@IDOrdineTestata uniqueidentifier
)
RETURNS VARCHAR(16)
AS
BEGIN
	
DECLARE @OrdiniErogatiTestate AS TABLE(StatoOrderEntry VARCHAR(16), StatoRisposta VARCHAR(16))
DECLARE @StatoOrderEntry AS VARCHAR(64) = NULL
	
	-- Leggo tutte le testate e poi le valuto
	INSERT INTO @OrdiniErogatiTestate(StatoOrderEntry, StatoRisposta)
	SELECT StatoOrderEntry, StatoRisposta
	FROM OrdiniErogatiTestate WITH(NOLOCK) WHERE IDOrdineTestata = @IDOrdineTestata 

	-- NON c'è una testate erogate con STATO NOT NULL
	IF NOT EXISTS (SELECT * FROM @OrdiniErogatiTestate WHERE StatoOrderEntry IS NOT NULL)
	BEGIN
		-- Popolare la tabella
		SELECT TOP 1 @StatoOrderEntry = ote.StatoRisposta
			FROM @OrdiniErogatiTestate ote
				INNER JOIN dbo.OrdiniErogatiStatiRisposta osr WITH(NOLOCK) ON ote.StatoRisposta = osr.Codice
			ORDER BY CASE osr.Codice WHEN 'AE' THEN 1
									WHEN 'AR' THEN 2
									WHEN 'AA' THEN 3
									WHEN 'SE' THEN 4
									ELSE 0 END

		-- Ritorna AA AR AR SE o NULL
		RETURN @StatoOrderEntry
	END

	-- Conto le testate aspettate
	DECLARE @Count int
	SELECT @Count = ISNULL(COUNT(*),0) FROM @OrdiniErogatiTestate

	-- Se tutte le testate erogate hanno lo stato CA
	DECLARE @CountCA int
	SELECT @CountCA = ISNULL(COUNT(*),0) FROM @OrdiniErogatiTestate WHERE StatoOrderEntry = 'CA'
	IF @CountCA > 0 AND @CountCA = @Count
		RETURN 'CA'
		
	-- Stato minimo sulle testate
    SELECT TOP 1 @StatoOrderEntry = ote.StatoOrderEntry
		FROM @OrdiniErogatiTestate ote
			INNER JOIN OrdiniErogatiStati oes WITH(NOLOCK) ON ote.StatoOrderEntry = oes.Codice
		WHERE ote.StatoOrderEntry <> 'CA'
		ORDER BY oes.Ordinamento

	IF @StatoOrderEntry IS NOT NULL
		RETURN @StatoOrderEntry

	RETURN NULL
END
