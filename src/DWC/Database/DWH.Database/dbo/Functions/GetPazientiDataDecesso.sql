-- =============================================
-- Author:		Ettore
-- Create date: 2013-05-17
-- Modify date: 2016-05-11 sandro - Usa nuovo campo
-- Description:	Ottiene la data di decesso
-- =============================================
CREATE FUNCTION [dbo].[GetPazientiDataDecesso] 
(
	@IdPaziente UNIQUEIDENTIFIER
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @DataDecesso DATETIME
	
	SELECT TOP 1 @DataDecesso = DataDecesso
		FROM [dbo].[SAC_Pazienti] AS P
		WHERE P.Id = @IdPaziente

	RETURN @DataDecesso 
END
