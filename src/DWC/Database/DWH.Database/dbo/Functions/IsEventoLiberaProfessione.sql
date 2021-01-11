-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-02-05
-- Description:	Controlla se il ricovero è in LP
-- =============================================
CREATE FUNCTION [dbo].[IsEventoLiberaProfessione] 
(
	@IdEvento uniqueidentifier
)
RETURNS [bit]
AS
BEGIN

	DECLARE @Ret bit = 0
	DECLARE @Valore sql_variant = NULL
	--
	-- Cerca attributi LP
	--  nel Ricovero
	--
	SELECT @Valore = [dbo].[GetRicoveriAttributo2](r.[Id], r.[DataPartizione], 'LiberaProfessione')
	FROM [store].[EventiBase] e
		INNER JOIN [store].[RicoveriBase] r
			ON e.[NumeroNosologico] = r.[NumeroNosologico]
				AND e.[AziendaErogante] = r.[AziendaErogante]
	WHERE e.[Id] = @IdEvento
	--
	-- Converte in BIT
	--
	IF NOT @Valore IS NULL
		SET @Ret = [dbo].[ConverteAttributoToBoolean](@Valore)

	RETURN @Ret
END