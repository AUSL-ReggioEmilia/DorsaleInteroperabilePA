
-- =============================================
-- Author:		ETTORE
-- Create date: 2014-07-28
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description:	Restituisce 1 se il nosologico passato è un nosologico di lista di attesa
--				Ho usato come discriminante la lunghezza dei codici delle notifiche di lista di attesa che è di due caratteri
--				mentre quelli dell'ADT sono di un carattere.
-- =============================================
CREATE FUNCTION [dbo].[IsNosologicoListaDiAttesa]
(
	@NumeroNosologico VARCHAR(64)
)
RETURNS BIT
AS
BEGIN
	--
	-- Variabile da restituire
	--
	DECLARE @Ret BIT

	DECLARE @TipoEventoCodice VARCHAR(2) 

	SET @Ret = 0
	
	SELECT TOP 1 
		@TipoEventoCodice = TipoEventoCodice 
	FROM store.EventiBase 
	WHERE 
		NumeroNosologico = @NumeroNosologico 
		-- ATTENZIONE:
		-- Non devo leggere il record "fittizio" con codice 'LA' che ha TipoEventoCodice di due caratteri e NumeroNosologico uguale a quello del ricovero associato ad una lista di attesa
		-- altrimenti per un "nosologico di ricovero" verrebbe restituito che è un nosologico di "lista di attesa".
		-- Tale record "fittizio" viene inserito dalla DataAccess per mantenere il collegamento fra "nosologico lista di attesa" e "nosologico di ricovero".
		-- 
		AND TipoEventoCodice <> 'LA'
		
	--
	-- Se TipoEventoCodice ha lunghezza 2 allora il nosologico è una lista di attesa
	--
	IF LEN(@TipoEventoCodice) = 2 
		SET @Ret = 1
	--
	-- Restituisco
	--
	RETURN @Ret

END
