-- =============================================
-- Author:		Ettore
-- Create date: 2015-11-12
-- Description:	Calcola la data minima di partizione da applicare come filtro alle Prescrizioni
-- =============================================
CREATE FUNCTION [dbo].[OttieniFiltroPrescrizioniPerDataPartizione]
(
	@DataDal DATETIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @Ret AS DATETIME
	DECLARE @AnniDaSottrarre AS INT = 2
	--Controllo se posso sottrarre 
	IF YEAR(@DataDal) >= 1753 + @AnniDaSottrarre
		SET @Ret = DATEADD(year, - @AnniDaSottrarre, @DataDal)
	
	RETURN @Ret

END