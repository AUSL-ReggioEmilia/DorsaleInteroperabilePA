









-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	Cancella logicamente il record di un evento
-- Modify date:	2013-03-05: tolto riferimenti a RicoveriLog
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2018-07-13 - ETTORE: Uso della nuova funzione dbo.GetEventiPk
-- Modify date: 2019-06-05 - ETTORE: Implementazione della cancellazione logica di un evento
--									 Il record evento cancellato logicamente viene posto a StatoCodice=3
-- Modify date: 2019-12-03 - ETTORE: In caso di cancellazione di evento A, se configurato , si cancellano tutti gli eventi validi del nosologico
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo a messaggio di errore "Evento non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiRimuovi]
(
	@IdEsterno  varchar(64)
)
AS

	DECLARE @IdEventiBase AS uniqueidentifier
	DECLARE @NumRecord int
	DECLARE @Error int
	DECLARE @DataPartizione		SMALLDATETIME
	DECLARE @AziendaErogante	VARCHAR(16)
	DECLARE @NumeroNosologico	VARCHAR(64)
	DECLARE @TipoEventoCodice	VARCHAR(16)=''
	DECLARE @RimuoviNosologico	BIT = 0
	

	SET NOCOUNT ON
	--------------------------------------------------------------------------------------------------------
	--- Cerca IdEvento
	--------------------------------------------------------------------------------------------------------
	-- Legge la PK e DataModificaEsterno 
	SELECT 
		@IdEventiBase = ID
		, @DataPartizione = DataPartizione
	FROM 
		[dbo].[GetEventiPk](@IdEsterno)

	IF @IdEventiBase IS NULL
	BEGIN
		--------------------------------------------------------------------------------------------------------
		--- Referto non trovato
		--------------------------------------------------------------------------------------------------------
		--SELECT DELETED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore ''Evento'' non trovato!', 16, 1)
		RETURN 1002
	END

	--
	-- Leggo la configurazione per capire se devo rimuovere tutti gli eventi in caso di "Rimozione di Accettazione"
	--
	SELECT @RimuoviNosologico = ISNULL(CAST([dbo].[GetConfigurazioneInt] ('DAE', 'RimozioneAccettazioneRimuoveRicovero') AS BIT), 0)


	--
	-- Determino il @TipoEventoCodice e [@AziendaERogante, @NumeroNosologico]
	-- Se @RimuoviNosologico = 0 non mi serve sapere il valore di @TipoEventoCodice 
	--
	IF @RimuoviNosologico = 1
	BEGIN 
		SELECT 
			@AziendaERogante = AziendaErogante
			, @NumeroNosologico = NumeroNosologico 
			, @TipoEventoCodice = TipoEventoCodice
		FROM 
			store.EventiBase
		WHERE Id = @IdEventiBase
			AND DataPartizione = @DataPartizione
	END 

	IF @RimuoviNosologico = 1 AND @TipoEventoCodice = 'A'
	BEGIN 
		----------------------------------------------------------------------------------
		-- Devo porre nello stato CANCELLATO tutti gli eventi ATTIVI del nosologico
		----------------------------------------------------------------------------------
		--
		-- Determino il postfisso
		--
		DECLARE @PostFisso VARCHAR(64) = '@' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(24), GETDATE(), 121), '-', ''), ' ' , ''), ':',''), '.', '')
		--
		-- Aggiorno 
		--
		UPDATE store.EventiBase
			SET StatoCodice = 3 --3=Cancellato da richiesta di RIMOZIONE
				--MODIFICO l'IdEsterno dell'evento aggiungendo la data
				,IdEsterno = IdEsterno + @PostFisso 
				, DataModifica = GETDATE()
		WHERE 
			AziendaErogante = @AziendaERogante
			AND NumeroNosologico = @NumeroNosologico
			AND StatoCodice = 0
			AND TipoEventoCodice IN ('A','T','D')
			-- Non aggiorno i record che sono stati già cancellati
			AND NOT IdEsterno LIKE ('%@%')  

		----------------------------------------------------------------------------------
		-- Memorizzo info
		----------------------------------------------------------------------------------
		SELECT @NumRecord = @@ROWCOUNT, @Error = @@ERROR 
		IF @Error <> 0 GOTO ERROR_EXIT
	END
	ELSE
	BEGIN 
		----------------------------------------------------------------------------------
		-- Funzionamento STANDARD
		-- Imposto StatoCodice = 3 =CANCELLATO LOGICAMENTE
		----------------------------------------------------------------------------------
		DECLARE @IdEsternoNew VARCHAR(64) = @IdEsterno + '@' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(24), GETDATE(), 121), '-', ''), ' ' , ''), ':',''), '.', '')
		UPDATE store.EventiBase
			SET StatoCodice = 3
				--MODIFICO l'IdEsterno dell'evento aggiungendo la data
				,IdEsterno = @IdEsternoNew 
				, DataModifica = GETDATE()
		WHERE Id=@IdEventiBase

		----------------------------------------------------------------------------------
		-- Memorizzo info
		----------------------------------------------------------------------------------
		SELECT @NumRecord = @@ROWCOUNT, @Error = @@ERROR 
		IF @Error <> 0 GOTO ERROR_EXIT
	END 
	--
	--
	--
	SELECT DELETED_COUNT=@NumRecord
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	SELECT DELETED_COUNT=0
	RETURN 1


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiRimuovi] TO [ExecuteExt]
    AS [dbo];

