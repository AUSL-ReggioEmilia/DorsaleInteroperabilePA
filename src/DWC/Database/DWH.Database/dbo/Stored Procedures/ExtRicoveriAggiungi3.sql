







-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- MODIFICA ETTORE 2015-09-02: Ora si utilizza la DataPartizione dell'evento e non la DataEvento
-- MODIFICA ETTORE 2016-09-08: eliminato filtro per SistemaErogante = 'ADT' per gestione nuovo sistema erogante EIM-ADTSTR
--								controllato il nuovo sistema erogante EIM-ADTSTR per la determinazione della data di partizione
-- MODIFICA ETTORE 2016-11-21: Escludo gli eventi LA dalla ricerca della data di partizione

-- MODIFICA ETTORE 2017-01-23: Modifico l'IdEsterno pasato dalla DAE per togliere il riferimento al sistema erogante
--								Prima l'IdEsterno era composto come <Azienda>_<SistemaErogante>_<NumeroNosologico> 
--								ora deve essere composto come <Azienda>_ADT_<NumeroNosologico>
--								Tolto anche l'IF che discriminava fra eventi ADT e non per il calcolo della DataPartizione
--								Poichè qualsiasi record di ricovero viene inserito dopo l'inserimento di un evento la DataPartizione la posso sempre 
--								ricavare dalla tabella deli eventi
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2020-02-13 ETTORE - Modificato il messaggio dei campi obbligatori 
--									Se almeno un campo obbligatorio non è valorizzato si mostra 
--									i valori di tutti i campi obbligatori, valorizzati e non.
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[ExtRicoveriAggiungi3]
(
	@IdEsterno 				varchar(64), 
	@IdPaziente				uniqueidentifier, 
	@StatoCodice			tinyint,
	@NumeroNosologico		varchar(64),
	@AziendaErogante		varchar(16),
	@SistemaErogante		varchar(16),
	@RepartoErogante		varchar(64),
	@OspedaleCodice			varchar(16),
	@OspedaleDescr			varchar(128),
	@TipoRicoveroCodice		varchar(16),
	@TipoRicoveroDescr		varchar(128),
	@Diagnosi				varchar(1024),
	@DataAccettazione		datetime,
	@RepartoAccettazioneCodice	varchar (16),
	@RepartoAccettazioneDescr	varchar (128),
	@DataTrasferimento			datetime,
	@RepartoCodice			varchar (16),
	@RepartoDescr			varchar (128),
	@SettoreCodice			varchar (16),
	@SettoreDescr			varchar (128),
	@LettoCodice			varchar (16),
	@DataDimissione			datetime,
	@XmlAttributi 			text = Null
)
AS
BEGIN
	/* 
	Il campo @XmlAttributi deve avere la seguente struttura:
		<?xml version="1.0" encoding="iso-8859-1" ?>
		<Root>
		<Attributo Nome="CodiceSaub" Valore="3456677"/>
		<Attributo Nome="CodiceUSL" Valore="0034577"/>
		</Root>
	Le date vanno convertite in stringa nel formato ISO8601 (yyyy-mm-ddThh:mm:ss.mmm)
	*/
	DECLARE @guidId uniqueidentifier
	DECLARE @xmlDoc int
	DECLARE @NumRecord int
	DECLARE @IdReparto uniqueidentifier
	DECLARE @DataPartizione smalldatetime

	--
	-- MODIFICA ETTORE 2017-01-23: Modifico l'IdEsterno pasato dalla DAE per togliere il riferimento al sistema erogante
	--
	SET @IdEsterno = REPLACE(@IdEsterno , '_' + @SistemaErogante + '_', '_ADT_')

	--
	-- Al momento della creazione del record del ricovero per come è fatta la DataAccess
	-- ci dovrebbe essere solo il primo evento
	--
	SELECT TOP 1 @DataPartizione = DataPartizione FROM store.EventiBase 
	WHERE AziendaErogante = @AziendaErogante 
		AND NumeroNosologico = @NumeroNosologico
		--MODIFICA ETTORE 2016-11-21: Escludo gli eventi LA dalla ricerca della data di partizione
		AND TipoEventoCodice <> 'LA'
	ORDER BY DataEvento ASC
	
	
	------------------------------------------------------
	--  Verifica dati
	------------------------------------------------------	
	IF (@IdPaziente IS NULL)
		OR ISNULL(@AziendaErogante, '') = '' OR ISNULL(@SistemaErogante, '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		--SELECT INSERTED_COUNT = NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		DECLARE @MsgParam VARCHAR(512) = 'Errore manca almeno un parametro obbligatorio. Valori dei parametri obbligatori: ' 
		SET @MsgParam = @MsgParam + ' @IdPaziente=' + ISNULL(CAST(@IdPaziente AS VARCHAR(40)), 'NULL') + ','
		SET @MsgParam = @MsgParam + ' @AziendaErogante=' + ISNULL(@AziendaErogante, 'NULL') + ','
		SET @MsgParam = @MsgParam + ' @SistemaErogante=' + ISNULL(@SistemaErogante, 'NULL') + ','
		SET @MsgParam = LEFT(@MsgParam , LEN(@MsgParam) - 1) + '.'
		RAISERROR(@MsgParam , 16, 1)
		RETURN 1010
	END

	------------------------------------------------------
	--  Creo Id dell'evento
	------------------------------------------------------	
	SET @guidId = NEWID()
	
	BEGIN TRANSACTION
	------------------------------------------------------
	--  		Eventi Base
	------------------------------------------------------	
	SET @AziendaErogante = RTRIM(@AziendaErogante)
	SET @SistemaErogante = RTRIM(@SistemaErogante)
	SET @RepartoErogante = NULLIF(RTRIM(@RepartoErogante),'') --modifica per gestione dei NULL
	SET @NumeroNosologico = RTRIM(@NumeroNosologico)
	SET @OspedaleCodice = NULLIF(RTRIM(@OspedaleCodice),'')
	SET @OspedaleDescr = NULLIF(RTRIM(@OspedaleDescr),'')
	SET @TipoRicoveroCodice = NULLIF(RTRIM(@TipoRicoveroCodice),'')
	SET @TipoRicoveroDescr = NULLIF(RTRIM(@TipoRicoveroDescr),'')
	SET @Diagnosi = NULLIF(RTRIM(@Diagnosi),'')
	SET @RepartoAccettazioneCodice = NULLIF(RTRIM(@RepartoAccettazioneCodice),'')
	SET @RepartoAccettazioneDescr = NULLIF(RTRIM(@RepartoAccettazioneDescr),'')
	SET @RepartoCodice = NULLIF(RTRIM(@RepartoCodice),'')
	SET @RepartoDescr = NULLIF(RTRIM(@RepartoDescr),'')
	SET @SettoreCodice = NULLIF(RTRIM(@SettoreCodice),'')
	SET @SettoreDescr = NULLIF(RTRIM(@SettoreDescr),'')
	SET @LettoCodice = NULLIF(RTRIM(@LettoCodice),'')
	
	SET NOCOUNT OFF	-- Per verificare se inserito

	INSERT INTO store.RicoveriBase(
			Id, IdEsterno, DataModificaEsterno, DataInserimento ,DataModifica
			,StatoCodice
			,Cancellato
			,NumeroNosologico, AziendaErogante, SistemaErogante, RepartoErogante
			,IdPaziente, OspedaleCodice, OspedaleDescr
			,TipoRicoveroCodice, TipoRicoveroDescr, Diagnosi
			,DataAccettazione, RepartoAccettazioneCodice, RepartoAccettazioneDescr
			,DataTrasferimento
			,RepartoCodice, RepartoDescr
			,SettoreCodice, SettoreDescr
			,LettoCodice, DataDimissione
			,DataPartizione
			)
	 VALUES 
			(
			@guidId, @IdEsterno, NULL, GETDATE(), GETDATE()
			,@StatoCodice
			,0
			,@NumeroNosologico, @AziendaErogante, @SistemaErogante, @RepartoErogante
			,@IdPaziente, @OspedaleCodice, @OspedaleDescr
			,@TipoRicoveroCodice, @TipoRicoveroDescr, @Diagnosi
			,@DataAccettazione, @RepartoAccettazioneCodice, @RepartoAccettazioneDescr
			,@DataTrasferimento
			,@RepartoCodice,@RepartoDescr
			,@SettoreCodice, @SettoreDescr
			,@LettoCodice, @DataDimissione
			,@DataPartizione
			)

	SET @NumRecord = @@ROWCOUNT
	IF @NumRecord = 0 GOTO ERROR_EXIT

	SET NOCOUNT ON

	------------------------------------------------------------------------------------------------------------
	--  		Reparti richiedenti: continuo ad usare la medesima struttura
	--			riferendomi al reparto corrente @RepartoCodice-@RepartoDescr
	------------------------------------------------------------------------------------------------------------	
	IF NOT @RepartoCodice IS NULL
	BEGIN
		SELECT @IdReparto = RepartiRichiedentiSistemiEroganti.Id
		FROM dbo.RepartiRichiedentiSistemiEroganti WITH(NOLOCK) INNER JOIN dbo.SistemiEroganti WITH(NOLOCK)
			ON RepartiRichiedentiSistemiEroganti.IdSistemaErogante = dbo.SistemiEroganti.Id
		WHERE RepartiRichiedentiSistemiEroganti.RepartoRichiedenteCodice = @RepartoCodice
			AND SistemiEroganti.AziendaErogante = @AziendaErogante
			AND SistemiEroganti.SistemaErogante = @SistemaErogante

		--PRINT @IdReparto

		IF @IdReparto IS NULL
			--
			--  Nuovo reparto di ricovero
			--
			INSERT INTO dbo.RepartiRichiedentiSistemiEroganti
				(IdSistemaErogante, RepartoRichiedenteCodice, RepartoRichiedenteDescrizione)
			SELECT Id, @RepartoCodice, @RepartoDescr
			FROM dbo.SistemiEroganti
			WHERE AziendaErogante = @AziendaErogante
				AND SistemaErogante = @SistemaErogante
		ELSE
			--
			--  Aggiorno reparto
			--
			UPDATE dbo.RepartiRichiedentiSistemiEroganti
			SET RepartoRichiedenteDescrizione = @RepartoDescr
			WHERE Id = @IdReparto
					AND RepartoRichiedenteDescrizione <> @RepartoDescr

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END 

	------------------------------------------------------------------------------------------------------------
	--  Inserimento degli attributi del Ricovero
	------------------------------------------------------------------------------------------------------------	

	---------------------------------------------------
	--  Aggiungo Attributi che sono presenti anche in RicoveroBase: NESSUNO
	---------------------------------------------------

	---------------------------------------------------
	--  Aggiungo Attributi presenti solo in RicoveroAttributi: NESSUNO
	---------------------------------------------------

	---------------------------------------------------
	--  Altri Attributi: è tramite questa parte che si inseriscono i dati anagrafici
	---------------------------------------------------
	IF DATALENGTH(@XmlAttributi) > 0 AND NOT @XmlAttributi IS NULL
		BEGIN 
			EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @XmlAttributi
			--
			-- Execute a SELECT statement using OPENXML rowset provider.
			--
			INSERT INTO store.RicoveriAttributi (IdRicoveriBase, Nome,  Valore, DataPartizione) 
				SELECT @guidId, Nome, LTRIM(RTRIM(Valore)), @DataPartizione
				FROM OPENXML (@xmlDoc, '/Root/Attributo',1)
				      WITH (Nome  varchar(64),
				            Valore varchar(8000))
				WHERE LEN(Valore) > 0

			IF @@ERROR <> 0
				BEGIN
				EXEC sp_xml_removedocument @xmlDoc
				GOTO ERROR_EXIT
				END
			ELSE
				BEGIN
				EXEC sp_xml_removedocument @xmlDoc
				END
		END

	---------------------------------------------------
	--     Completato
	---------------------------------------------------

	COMMIT
	SELECT INSERTED_COUNT=@NumRecord
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	SELECT INSERTED_COUNT=0
	RETURN 1

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRicoveriAggiungi3] TO [ExecuteExt]
    AS [dbo];

