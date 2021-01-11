

-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-27
-- Description:	Calcola la data minima di partizione da applicare come filtro alle NoteAnamnestiche
-- =============================================
CREATE FUNCTION [dbo].[OttieniFiltroNoteAnamnestichePerDataPartizione]
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