
-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- MODIFICA ETTORE 2015-03-02: modificata per utilizzare la vista EventiBase 
-- MODIFICA ETTORE 2016-09-08: eliminato filtro per SistemaErogante = 'ADT' per gestione nuovo sistema erogante EIM-ADTSTR
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetEventiIdEventoAccettazione]
(
	@AziendaErogante VARCHAR(16)
	,@NumeroNosologico  varchar(64)
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
--
-- Si presuppone che un episodio inizi con una ACCETTAZIONE
--
	DECLARE @ReturnValue UNIQUEIDENTIFIER

	SELECT TOP 1 
		@ReturnValue = Id
	FROM 
		store.EventiBase
	WHERE 
		AziendaErogante = @AziendaErogante
		--AND SistemaErogante = 'ADT'
		AND	NumeroNosologico = @NumeroNosologico 
		AND TipoEventoCodice= 'A'
		AND StatoCodice = 0 --solo ATTIVI non ERASED

	ORDER BY DataEvento ASC --DESC


	RETURN @ReturnValue 

END

