


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- MODIFICA ETTORE 2015-03-02: modificata per utilizzare la vista EventiBase 
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
--									 Tolto il filtro "AND SistemaErogante = 'ADT'"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveroRepartoErogante]
(
	@AziendaErogante VARCHAR(16)
	,@NumeroNosologico  varchar(64)
)
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @ReturnValue VARCHAR(64)

	SELECT TOP 1 
		@ReturnValue = RepartoErogante
	FROM 
		store.EventiBase
	WHERE 
		AziendaErogante = @AziendaErogante
		--AND SistemaErogante = 'ADT'
		AND NumeroNosologico = @NumeroNosologico 
		AND	TipoEventoCodice= 'A'
		AND StatoCodice = 0 --solo ATTIVI non ERASED

	ORDER BY DataEvento ASC --DESC

	RETURN ISNULL(@ReturnValue ,'')

END


