

-- =============================================
-- Author:		Marco Bellini
-- Create date: 2012-02-08
-- Modify date: 2012-02-08
-- Description:	Ritorna lo stato erogato order entry minimo delle testate erogate
-- =============================================
CREATE FUNCTION [dbo].[GetMinStatoErogatoTestateOrderEntry](
	@IDOrdineTestata uniqueidentifier
)
RETURNS varchar(16)
AS
BEGIN

	if (SELECT ISNULL(COUNT(*),0) FROM OrdiniErogatiTestate WHERE StatoOrderEntry is not null AND IDOrdineTestata = @IDOrdineTestata) = 0
	begin
		return null
	end

	-- Se tutte le testate erogate hanno lo stato o.e. uguale a CA
	DECLARE @CountCA int, @Count int
	
	SELECT @Count = ISNULL(COUNT(*),0) FROM OrdiniErogatiTestate WHERE StatoOrderEntry <> 'CA' AND IDOrdineTestata = @IDOrdineTestata
	
	SELECT @CountCA = ISNULL(COUNT(*),0) FROM OrdiniErogatiTestate WHERE StatoOrderEntry = 'CA' AND IDOrdineTestata = @IDOrdineTestata
	IF @CountCA > 0
	BEGIN
		IF @Count = 0 RETURN 'CA'		
		IF @CountCA = @Count RETURN 'CA'
	END
	
	-- Se tutte le testate erogate hanno lo stato o.e. uguale a CM, escluse le CA
	DECLARE @CountCM int 
	
	SELECT @CountCM = ISNULL(COUNT(*),0) FROM OrdiniErogatiTestate WHERE StatoOrderEntry = 'CM' AND IDOrdineTestata = @IDOrdineTestata
	IF @CountCM + @CountCA = @Count RETURN 'CM'		
	
	if (select count(*) FROM OrdiniErogatiTestate WHERE StatoOrderEntry = 'IC') > 0
		return 'IC'
	else
		return 'IP'
	
	return ''--non può accadere
END
