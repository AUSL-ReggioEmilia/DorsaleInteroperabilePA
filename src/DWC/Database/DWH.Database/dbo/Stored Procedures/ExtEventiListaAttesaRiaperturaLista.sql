


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	Riapre una lista di attesa
-- MODIFICA ETTORE 2015-02-24: aggiunto uso della funzione @@ERROR, prima c'era un TRY CATCH che mascherava errore dead lock
-- MODIFICA ETTORE 2016-12-15: migliorate le prestazioni di ricerca dell'evento LA aggiungendo il filtro per paziente
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore "Evento lista di attesa RL non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiListaAttesaRiaperturaLista]
(
	@IdEsterno 	VARCHAR(64) --questo è l'IdEsterno dell'evento RL
)
AS
BEGIN
/*
	La SP deve riaprire la lista di attesa:
	1) Nasconde il record DL della chiusura 
		(poichè in seguito ad una notifica RL arriverà anche una notifica X degli ADT-Ricoveri quindi sia il ricovero in RicoveriBase che 
		il blocco di eventi <Azienda,Nosologico> 
	2) Nascondo il record LA che non viene nascosto in seguito alla X (la X nasconde solo gli A,D,T)

*/
	SET NOCOUNT ON;
	
	DECLARE @IdEventoRL			uniqueidentifier
	DECLARE @CodiceListaAttesa	varchar (64)  --lo trovo nel campo NumeroNosologico dell'evento RL
	DECLARE @DataPartizione		smalldatetime
	DECLARE @IdEventoDL			uniqueidentifier
	DECLARE @AziendaErogante	varchar (16)
	DECLARE @SistemaErogante	varchar (16)
	DECLARE @Error				integer	
	DECLARE @IdPazienteRL		UNIQUEIDENTIFIER

	
	SELECT 
		@IdEventoRL = Id
		, @AziendaErogante = AziendaErogante
		, @SistemaErogante = SistemaErogante	
		, @CodiceListaAttesa = NumeroNosologico  -----leggo il codice della lista di attesa dal nosologico
		, @IdPazienteRL = IdPaziente
	FROM 
		store.EventiBAse 
	WHERE 
		IdEsterno = @IdEsterno 
		
	IF @IdEventoRL IS NULL
	BEGIN
		--------------------------------------------------------------------------------------------------------
		--- Evento RL non trovato
		--------------------------------------------------------------------------------------------------------
		--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore: Evento lista di attesa RL non trovato!', 16, 1)
		RETURN 1002
	END
	
	BEGIN TRANSACTION
		--
		-- 1) Nascondo tutti i DL visibili (ce ne dovrebbe essere uno solo)
		--	
		DECLARE @TempTbl AS TABLE(Id UNIQUEIDENTIFIER)
		INSERT INTO @TempTbl (Id)
		SELECT 
			Id 
		FROM store.EventiBase 
		WHERE 
			AziendaErogante = @AziendaErogante
			AND SistemaErogante = @SistemaErogante
			AND NumeroNosologico = @CodiceListaAttesa -----filtro per codice della lista di attesa
			AND TipoEventoCodice = 'DL'
			AND StatoCodice = 0
		
		UPDATE store.EventiBase
			SET StatoCodice = 1
		FROM store.EventiBase 
			INNER JOIN @TempTbl AS TAB
				ON EventiBase.Id = TAB.ID
		SET @Error = @@ERROR
		IF @Error <> 0 GOTO ERROR_EXIT


		--
		-- MODIFICA ETTORE 2016-12-15: calcolo tabella IdPaziente con tuti gli Id della catena di fusione
		--
		DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER
		SELECT @IdPazienteAttivo = dbo.GetPazienteAttivoByIdSac(@IdPazienteRL)
		-- Lista dei fusi + l'attivo
		--
		DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
		INSERT INTO @TablePazienti(Id)
			SELECT Id
			FROM dbo.GetPazientiDaCercareByIdSac(@IdPazienteAttivo)
				
		--
		-- 2) Nascondo il record LA associato alla lista di attesa
		--	
		DECLARE @IdEventoLA UNIQUEIDENTIFIER
		DECLARE @NumeroNosologico AS VARCHAR(64)
		SELECT 
			@IdEventoLA = E.Id
			, @NumeroNosologico = E.NumeroNosologico
		FROM store.EventiBase AS E 
			--Filtro paziente			
			INNER JOIN @TablePazienti AS P
				ON E.IdPaziente = P.Id
			INNER JOIN store.EventiAttributi AS EA
				ON E.Id = EA.IdEventiBase And Nome = 'CodiceListaAttesa'
		WHERE AziendaErogante = @AziendaErogante
				AND SistemaErogante = @SistemaErogante
				AND TipoEventoCodice = 'LA'
				AND CAST(Valore AS VARCHAR(64)) = @CodiceListaAttesa
				
		UPDATE store.EventiBase 		
			SET StatoCodice = 1
		WHERE 
			AziendaErogante = @AziendaErogante
			AND SistemaErogante = @SistemaErogante
			AND NumeroNosologico = @NumeroNosologico
			AND TipoEventoCodice = 'LA'
		SET @Error = @@ERROR
		IF @Error <> 0 GOTO ERROR_EXIT
			
		--
		-- COMMIT
		--
		COMMIT
		---------------------------------------------------
		-- Completato
		-- Simulo aggiornamento completato
		---------------------------------------------------
		SELECT INSERTED_COUNT = 1
		RETURN 0	

ERROR_EXIT:
		--
		-- ROLLBACK
		--
		IF @@TRANCOUNT > 0		
			ROLLBACK
		---------------------------------------------------
		--     Error
		---------------------------------------------------
		SELECT INSERTED_COUNT=0
		RETURN @Error
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiListaAttesaRiaperturaLista] TO [ExecuteExt]
    AS [dbo];

