


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modify date: 2015/09/02 - ETTORE: se lista di attesa la data di partizione si calcola derivandola da GETDATE()
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	Aggiunge un evento 
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiAggiungi] 
 (	
	@IdEsterno 				varchar (64),
	@IdEsternoPaziente		varchar (64),
	@AziendaErogante 		varchar (16),
	@SistemaErogante 		varchar (16),
	@RepartoErogante 		varchar (64),
	@DataEvento 			datetime,
	@NumeroNosologico 		varchar (64),
	@TipoEventoCodice 		varchar (16),
	@TipoEventoDescr		varchar(128), --da scrivere in eventi base
	@TipoEpisodio			varchar(16),
	@TipoEpisodioDescr		varchar(128), --da scrivere negli attributi
	@RepartoCodice	varchar (16), 
	@RepartoDescr	varchar (128), 
	@Diagnosi				varchar(1024),
	@XmlAttributi 			text = Null
) AS
/* 
Il campo @XmlAttributi deve avere la seguente struttura:
    <?xml version="1.0" encoding="iso-8859-1" ?>
    <Root>
	<Attributo Nome="CodiceSaub" Valore="3456677"/>
	<Attributo Nome="CodiceUSL" Valore="0034577"/>
    </Root>
Le date vanno convertite in stringa nel formato ISO8601 (yyyy-mm-ddThh:mm:ss.mmm)

MODIFICA ETTORE 02/09/2015: se lista di attesa la data di partizione si calcola derivandola da GETDATE()
*/
DECLARE @IdPaziente uniqueidentifier
DECLARE @guidId uniqueidentifier
DECLARE @xmlDoc int
DECLARE @NumRecord int
DECLARE @IdReparto uniqueidentifier
--
-- Gestione della data di partizione
--
DECLARE @DataPartizione smalldatetime

	SET NOCOUNT ON

	------------------------------------------------------
	--  Verifica dati
	------------------------------------------------------	
	IF ISNULL(@IdEsterno, '') = '' OR ISNULL(@IdEsternoPaziente, '') = ''
			OR ISNULL(@AziendaErogante, '') = '' OR ISNULL(@SistemaErogante, '') = ''
			OR @DataEvento IS NULL
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdEsterno, @IdEsternoPaziente, @AziendaErogante, @SistemaErogante, @DataEvento)!', 16, 1)
		RETURN 1010
	END
	--
	-- Originale: SET @DataPartizione = @DataEvento	
	--
	-- Uso sempre la medesima data di partizione per eventi dello stesso nosologico
	--	
	SELECT TOP 1 @DataPartizione = DataPartizione FROM store.EventiBase 
	WHERE AziendaErogante = @AziendaErogante 
		AND SistemaErogante = @SistemaErogante
		AND NumeroNosologico = @NumeroNosologico
	IF @DataPartizione IS NULL 
	BEGIN
		-- Allora è il primo evento
		IF @TipoEventoCodice IN ('IL', 'ML', 'DL', 'RL', 'SL') --evento di lista di attesa
			SET @DataPartizione = GETDATE()
		ELSE
			SET @DataPartizione = @DataEvento
	END

	------------------------------------------------------
	--  Cerca IdPaziente e nuovo IdEvento
	------------------------------------------------------	
	SET @guidId = NEWID()
	IF @IdEsternoPaziente = '00000000-0000-0000-0000-000000000000'
		SET @IdPaziente = CAST(@IdEsternoPaziente AS UNIQUEIDENTIFIER)
	ELSE
		SET @IdPaziente = dbo.GetPazientiIdByDipartimento( @IdEsternoPaziente)
	
	IF @IdPaziente IS NULL
	BEGIN
		------------------------------------------------------
		--Errore se no paziente
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore paziente non trovato!', 16, 1)
		RETURN 1001
	END
	
	BEGIN TRANSACTION
	
	------------------------------------------------------
	--  		Eventi Base
	------------------------------------------------------	
	SET @AziendaErogante = RTRIM(@AziendaErogante)
	SET @SistemaErogante = RTRIM(@SistemaErogante)
	SET @RepartoErogante = NULLIF(RTRIM(@RepartoErogante),'')	--modifica per gestione NULL
	SET @NumeroNosologico = RTRIM(@NumeroNosologico)
	SET @RepartoCodice = NULLIF(RTRIM(@RepartoCodice),'')		--modifica per gestione NULL
	SET @RepartoDescr = NULLIF(RTRIM(@RepartoDescr),'')			--modifica per gestione NULL
	SET @TipoEpisodio = NULLIF(RTRIM(@TipoEpisodio),'')			--NUOVO: modifica per gestione NULL
	SET @Diagnosi = NULLIF(RTRIM(@Diagnosi),'')					--NUOVO: modifica per gestione NULL
	
	SET NOCOUNT OFF	-- Per verificare se inserito

	INSERT INTO store.EventiBase
	  (	
		Id,
		IdEsterno,
		DataModificaEsterno,
		IdPaziente,
		DataInserimento,
		DataModifica,
		AziendaErogante,
		SistemaErogante,
		RepartoErogante,
		DataEvento,
		StatoCodice,
		TipoEventoCodice,
		TipoEventoDescr,
		NumeroNosologico,
		TipoEpisodio,
		RepartoCodice,
		RepartoDescr,
		Diagnosi,
		DataPartizione
	 )
	VALUES
	 (
		@guidId,
		@IdEsterno,
		NULL,
		@IdPaziente,		
		GetDate(),
		GetDate(),
		@AziendaErogante,
		@SistemaErogante,
		@RepartoErogante,
		@DataEvento,
		0,
		@TipoEventoCodice,
		@TipoEventoDescr,
		@NumeroNosologico,
		@TipoEpisodio,
		@RepartoCodice,
		@RepartoDescr,
		@Diagnosi,
		@DataPartizione
	 )

	SET @NumRecord = @@ROWCOUNT
	IF @NumRecord = 0 GOTO ERROR_EXIT

	SET NOCOUNT ON

	------------------------------------------------------------------------------------------------------------
	--  		Reparti richiedenti: continuo ad usare la medesima struttura
	------------------------------------------------------------------------------------------------------------	
	IF NOT @RepartoCodice IS NULL
	BEGIN
		SELECT @IdReparto = RepartiRichiedentiSistemiEroganti.Id
		FROM dbo.RepartiRichiedentiSistemiEroganti WITH(NOLOCK) INNER JOIN dbo.SistemiEroganti WITH(NOLOCK)
			ON RepartiRichiedentiSistemiEroganti.IdSistemaErogante = dbo.SistemiEroganti.Id
		WHERE RepartiRichiedentiSistemiEroganti.RepartoRichiedenteCodice = RTRIM(@RepartoCodice) 
			AND SistemiEroganti.AziendaErogante = RTRIM(@AziendaErogante)
			AND SistemiEroganti.SistemaErogante = RTRIM(@SistemaErogante)

		--PRINT @IdReparto

		IF @IdReparto IS NULL
			--
			--  Nuovo reparto di ricovero
			--
			INSERT INTO dbo.RepartiRichiedentiSistemiEroganti
				(IdSistemaErogante, RepartoRichiedenteCodice, RepartoRichiedenteDescrizione)
			SELECT Id, RTRIM(@RepartoCodice), RTRIM(@RepartoDescr)
			FROM dbo.SistemiEroganti
			WHERE AziendaErogante = RTRIM(@AziendaErogante)
				AND SistemaErogante = RTRIM(@SistemaErogante)
		ELSE
			--
			--  Aggiorno reparto
			--
			UPDATE dbo.RepartiRichiedentiSistemiEroganti
			SET RepartoRichiedenteDescrizione = RTRIM(@RepartoDescr)
			WHERE Id = @IdReparto
					AND RepartoRichiedenteDescrizione <> RTRIM(@RepartoDescr)

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END
	------------------------------------------------------------------------------------------------------------
	--  Inserimento degli attributi degli Eventi
	------------------------------------------------------------------------------------------------------------	

	---------------------------------------------------
	--  Attributi già in EventiBase: NESSUNO
	---------------------------------------------------

	---------------------------------------------------
	--  Attributi presenti solo in EventiAttributi:
	---------------------------------------------------
	IF LTRIM(RTRIM(@TipoEpisodioDescr))<>'' AND NOT @TipoEpisodioDescr IS NULL
		BEGIN
			INSERT INTO store.EventiAttributi (IdEventiBase, Nome,  Valore, DataPartizione) 
			VALUES (@guidId, 'TipoEpisodioDescr', LTRIM(RTRIM(@TipoEpisodioDescr)), @DataPartizione)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END

	---------------------------------------------------
	--  Altri Attributi: è tramite questa parte che si inseriscono i dati anagrafici
	---------------------------------------------------
	IF DATALENGTH(@XmlAttributi) > 0 AND NOT @XmlAttributi IS NULL
		BEGIN 
			EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @XmlAttributi
			--
			-- Execute a SELECT statement using OPENXML rowset provider.
			--
			INSERT INTO store.EventiAttributi (IdEventiBase, Nome,  Valore, DataPartizione) 
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


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiAggiungi] TO [ExecuteExt]
    AS [dbo];

