



-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- MODIFICA ETTORE 2015-03-02: modificata per utilizzare la vista EventiBase 
-- MODIFICA ETTORE 2016-10-13: L'evento X si deve comportare come l'evento E
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2019-06-27 - ETTORE: per ricavare ultimo evento A,T,D ordino per DataEvento DESC 
--									 per E,X ordino per DataModificaEsterno COME PRIMA
--									 per R	 ordino per DataModificaEsterno COME PRIMA
--									 Di fatto solo per gli eventi A, D, T che sono quelli che possono essere cancellati devono essere ordinati per DataEvento
--									 Quindi quando si deve creare un filotto di eventi si deve fare E + A,D,T ordinati per DataEvento.
-- Description:	
-- =============================================
CREATE FUNCTION [test].[dbo_GetRicoveroStatoCodice]
(
	@AziendaErogante VARCHAR(16)
	,@NumeroNosologico  varchar(64)
)
RETURNS INT
AS
BEGIN
	--
	-- In futuro si dovrà gestire anche lo stato Prenotato=0
	--
	DECLARE @ReturnValue INT
	DECLARE @UltimoEvento_TipoEventoCodice AS VARCHAR(16)
	DECLARE @UltimoEvento_DataModificaEsterno AS DATETIME

	SET @ReturnValue = 255 --Ricovero in stato indefinito: non c'è A, non è ANNULLATO, non è ERASED
	SET @UltimoEvento_DataModificaEsterno = NULL

	DECLARE @EsisteAccettazione BIT
	SET @EsisteAccettazione = 0
	--
	-- Determino se il ricovero è valido: se esiste l'accettazione
	--
	IF EXISTS(SELECT * FROM store.EventiBase
			WHERE AziendaErogante = @AziendaErogante
			AND NumeroNosologico = @NumeroNosologico
				AND TipoEventoCodice = 'A' AND StatoCodice = 0) --solo ATTIVI non ERASED
		SET @EsisteAccettazione = 1

	--
	-- Cerco se presenti A, T, D:
	-- Per A,T,D uso DataEvento per ordinare
	--
	SELECT TOP 1
		@UltimoEvento_TipoEventoCodice = TipoEventoCodice
		, @UltimoEvento_DataModificaEsterno = DataModificaEsterno
	FROM
		store.EventiBase
	WHERE 
		AziendaErogante = @AziendaErogante
		AND NumeroNosologico = @NumeroNosologico
		AND StatoCodice = 0 AND TipoEventoCodice IN ('A', 'T', 'D')
	ORDER BY
		DataEvento DESC 
		, CASE TipoEventoCodice 
			WHEN 'D' THEN 1
			WHEN 'T' THEN 2
			WHEN 'A' THEN 3 END ASC --creo un ordinamento per tipo di evento D=maggiore priorità, A=minore priorità

	--
	-- Se non ho trovato eventi cerco in EventiBase
	-- l'evento E,X, ordinando per DataModificaEsterno
	--
	IF @UltimoEvento_TipoEventoCodice IS NULL
	BEGIN
		SELECT TOP 1
			@UltimoEvento_TipoEventoCodice = TipoEventoCodice
		FROM
			store.EventiBase 
		WHERE 
			AziendaErogante = @AziendaErogante
			AND NumeroNosologico = @NumeroNosologico
			--MODIFICA ETTORE 2016-10-16: Evento X si comporta come E
			AND StatoCodice = 0 AND TipoEventoCodice IN ('E', 'X') 
		ORDER BY
			DataModificaEsterno DESC
	END
	ELSE 
	IF @UltimoEvento_TipoEventoCodice = 'T'
	BEGIN
		--
		-- Controllo se DOPO evento T nella EventiBase c'è un evento R: in questo caso devo segnalare l'apertura
		-- Ora @UltimoEvento_DataModificaEsterno è la data sequenza dell'ultimo evento T
		--
		-- Esiste un R con data maggiore dell'ultimo evento T? -> allora l'ultimo evento arrivato è una RIAPERTURA
		--
		SELECT TOP 1
			@UltimoEvento_TipoEventoCodice = TipoEventoCodice
		FROM
			store.EventiBase
		WHERE 
			AziendaErogante = @AziendaErogante
			AND NumeroNosologico = @NumeroNosologico
			AND StatoCodice = 0 AND TipoEventoCodice IN ('R')
			AND DataModificaEsterno > @UltimoEvento_DataModificaEsterno
		ORDER BY
			DataModificaEsterno DESC 
	END
			


	IF @EsisteAccettazione = 1 
	BEGIN
		IF @UltimoEvento_TipoEventoCodice = 'A' 
			SET @ReturnValue = 1 
		ELSE 
		IF @UltimoEvento_TipoEventoCodice = 'T' 
			SET @ReturnValue = 2 
		ELSE 
		IF @UltimoEvento_TipoEventoCodice = 'D' 
			SET @ReturnValue = 3 
		ELSE 
		IF @UltimoEvento_TipoEventoCodice = 'R' 
			SET @ReturnValue = 4 
	END
	ELSE 
	BEGIN
		--MODIFICA ETTORE 2016-10-16: Evento X si comporta come E
		IF @UltimoEvento_TipoEventoCodice IN ('E', 'X')
			SET @ReturnValue = 5 
	END
	--
	--
	--
	RETURN @ReturnValue 
END