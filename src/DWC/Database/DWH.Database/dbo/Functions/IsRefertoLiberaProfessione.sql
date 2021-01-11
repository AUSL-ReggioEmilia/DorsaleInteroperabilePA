-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-02-05
-- Description:	Converte un ATTRIBUTO in BIT
-- =============================================
CREATE FUNCTION [dbo].[IsRefertoLiberaProfessione] 
(
	@IdReferto uniqueidentifier
)
RETURNS [bit]
AS
BEGIN

	DECLARE @Ret bit = 0
	DECLARE @Valore sql_variant = NULL
	--
	-- Cerca attributi LP
	--
	SELECT @Valore = [dbo].[GetRefertiAttributo2](Id, DataPartizione, 'LiberaProfessione')
	FROM [store].[RefertiBase]
	WHERE Id = @IdReferto
	--
	-- Converte in BIT
	--
	IF NOT @Valore IS NULL
		SET @Ret = [dbo].[ConverteAttributoToBoolean](@Valore)

	RETURN @Ret
END