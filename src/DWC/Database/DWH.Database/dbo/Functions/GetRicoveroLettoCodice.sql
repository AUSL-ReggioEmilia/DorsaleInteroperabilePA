﻿


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- MODIFICA ETTORE 2015-03-02: modificata per utilizzare la vista EventiBase 
-- MODIFICA ETTORE 2016-09-08: eliminato filtro per SistemaErogante = 'ADT' per gestione nuovo sistema erogante EIM-ADTSTR
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveroLettoCodice]
(
	@AziendaErogante VARCHAR(16)
	,@NumeroNosologico  varchar(64)
)
RETURNS VARCHAR(16)
AS
BEGIN
--
-- Restituisce il codice del letto relativo all'ultimo evento
--
	DECLARE @ReturnValue VARCHAR(16)

	SELECT TOP 1
		@ReturnValue = CONVERT(VARCHAR(16), dbo.GetEventiAttributo(Eventi.Id, 'LettoCodice'))
	FROM 
		store.EventiBase AS Eventi
	WHERE 
		AziendaErogante = @AziendaErogante
		--AND SistemaErogante = 'ADT'
		AND (NumeroNosologico = @NumeroNosologico)
		AND (TipoEventoCodice IN ('A','T'))
		AND StatoCodice = 0 --solo ATTIVI non ERASED
		
	ORDER BY
		DataEvento DESC

	RETURN @ReturnValue 


END


