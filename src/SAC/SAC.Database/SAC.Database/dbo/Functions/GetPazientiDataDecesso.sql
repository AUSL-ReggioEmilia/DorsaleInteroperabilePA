-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetPazientiDataDecesso] 
(
	@IdPaziente UNIQUEIDENTIFIER
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @DataDecesso DATETIME
	SET @DataDecesso = NULL
	SELECT TOP 1
		@DataDecesso = DataDecesso
	FROM 
		PazientiDecessi AS P WITH(NOLOCK)
	WHERE 
		P.IdPaziente = @idPaziente
	ORDER BY 
		CASE WHEN P.Provenienza = 'LHA' THEN 2 
			 WHEN P.Provenienza = 'GST_ASMN' THEN 1 
			 WHEN P.Provenienza = 'GST_AUSL' THEN 1
			 ELSE 0
		END DESC
		, P.DataModifica DESC --maggiore data modifica	
	-- 
	-- Restituisco la data
	--
	RETURN @DataDecesso 
END
