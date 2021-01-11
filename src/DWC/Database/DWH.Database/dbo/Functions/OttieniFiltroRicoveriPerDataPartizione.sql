
-- =============================================
-- Author:		Ettore
-- Create date: 2015-05-22
-- Description:	Calcola la data minima di partizione da applicare come filtro ai ricoveri
-- =============================================
CREATE FUNCTION [dbo].[OttieniFiltroRicoveriPerDataPartizione]
(
	@DataDal DATETIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @Ret AS DATETIME
	DECLARE @AnniDaSottrarre AS INT = 3
	--Controllo se posso sottrarre 
	IF YEAR(@DataDal) >= 1753 + @AnniDaSottrarre
		SET @Ret = DATEADD(year, - @AnniDaSottrarre, @DataDal)
	
	RETURN @Ret

END

