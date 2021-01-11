


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- MODIFICA ETTORE 2015-03-02: modificata per utilizzare la vista EventiBase 
-- MODIFICA ETTORE 2016-09-08: eliminato filtro per SistemaErogante = 'ADT' per gestione nuovo sistema erogante EIM-ADTSTR
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveroDataDimissione]
(
	@AziendaErogante VARCHAR(16)
	,@NumeroNosologico  varchar(64)
)
RETURNS DATETIME
AS
BEGIN
--
-- Si presuppone che un episodio FINISCA con una DIMISSIONE
--
	DECLARE @ReturnValue DATETIME
	DECLARE @MaxDataEvento DATETIME
	--
	-- Trovo la data massima fra tutti gli eventi di tipo D 
	-- all'interno del nosologico
	--

	SELECT 
		@ReturnValue = MAX(DataEvento)
	FROM 
		store.EventiBase
	WHERE 
		AziendaErogante = @AziendaErogante
		--AND SistemaErogante = 'ADT'
		AND (NumeroNosologico = @NumeroNosologico)
		AND (TipoEventoCodice= 'D')
		AND StatoCodice = 0 --solo ATTIVI non ERASED

	RETURN @ReturnValue 

END


