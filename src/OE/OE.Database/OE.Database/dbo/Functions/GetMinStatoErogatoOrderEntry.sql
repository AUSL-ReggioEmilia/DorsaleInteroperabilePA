
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-03-18
-- Modify date: 2014-08-14 SANDRO: WITH(NOLOCK)
-- Modify date: 2015-02-18 SANDRO: Tabella temp per fare solo una query
-- Description:	Ritorna lo stato erogato order entry minimo
-- =============================================
CREATE FUNCTION [dbo].[GetMinStatoErogatoOrderEntry]
(
	@IDOrdineErogatoTestata uniqueidentifier
)
RETURNS varchar(16)
AS
BEGIN

DECLARE @OrdiniRigheErogate AS TABLE(StatoOrderEntry VARCHAR(16))
DECLARE @StatoOrderEntry varchar(16)

	-- Leggo tutte le testate e poi le valuto
	INSERT INTO @OrdiniRigheErogate(StatoOrderEntry)
		SELECT [StatoOrderEntry]
		FROM dbo.[OrdiniRigheErogate] WITH(NOLOCK)
		WHERE [IDOrdineErogatoTestata] = @IDOrdineErogatoTestata

	-- Se tutte le righe erogate hanno lo stato o.e. uguale a CA
	DECLARE @CountCA int
	DECLARE @Count int
	
	SELECT @CountCA = COUNT(*) FROM @OrdiniRigheErogate WHERE StatoOrderEntry = 'CA'
	SELECT @Count = COUNT(*) FROM @OrdiniRigheErogate WHERE StatoOrderEntry <> 'CA'
	
	IF ISNULL(@CountCA, 0) > 0
	BEGIN
		IF ISNULL(@Count, 0) = 0 RETURN 'CA'		
		IF @CountCA = @Count RETURN 'CA'
	END
	
	-- Totale Righe Richieste
    SELECT TOP 1 @StatoOrderEntry = StatoOrderEntry
		FROM @OrdiniRigheErogate ore INNER JOIN OrdiniRigheErogateStati WITH(NOLOCK)
			ON ore.StatoOrderEntry = OrdiniRigheErogateStati.Codice
		WHERE StatoOrderEntry <> 'CA'
		ORDER BY OrdiniRigheErogateStati.Ordinamento

	-- Return	
	RETURN @StatoOrderEntry
END
