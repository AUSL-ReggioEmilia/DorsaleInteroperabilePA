

-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modifica Ettore 2013-03-05: tolto riferimenti a RicoveriLog
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2018-07-13 - ETTORE: Uso della nuova funzione dbo.GetEventiPk che restituisce anche la data di partizione
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiModifica]
(	
	@IdEsterno 				varchar (64),
	@IdEsternoPaziente		varchar (64),
	@AziendaErogante 		varchar (16),
	@SistemaErogante 		varchar (16),
	@RepartoErogante 		varchar (64),
	@DataEvento 			datetime,
	@NumeroNosologico 		varchar (64),
	@TipoEventoCodice 		varchar (16) ,
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
*/
DECLARE @guidId AS uniqueidentifier
DECLARE @IdPaziente AS uniqueidentifier
DECLARE @xmlDoc int
DECLARE @NumRecord int
DECLARE @IdReparto AS uniqueidentifier
DECLARE @DataPartizione as smalldatetime

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
		
	------------------------------------------------------
	--  Cerca IdEvento e IdPaziente
	------------------------------------------------------	
	--SET @guidId = dbo.GetEventiId( @IdEsterno)
	-- Legge la PK e DataModificaEsterno 
	SELECT 
		@guidId = ID
		, @DataPartizione = DataPartizione
	FROM 
		[dbo].[GetEventiPk](@IdEsterno)

	IF @IdEsternoPaziente = '00000000-0000-0000-0000-000000000000'
		SET @IdPaziente = CAST(@IdEsternoPaziente AS UNIQUEIDENTIFIER)
	ELSE
		SET @IdPaziente = dbo.GetPazientiIdByDipartimento( @IdEsternoPaziente)

	IF @IdPaziente IS NULL
		BEGIN
		------------------------------------------------------
		--Errore se no paziente
		------------------------------------------------------
		SELECT INSERTED_COUNT=NULL
		RAISERROR('Errore ''paziente'' non trovato!', 16, 1)
		RETURN 1001
		END

	IF NOT @guidId IS NULL
		BEGIN
			SET @NumRecord = 0
		
			SET NOCOUNT OFF	-- Per verificare se inserito
			
			SET @AziendaErogante = RTRIM(@AziendaErogante)
			SET @SistemaErogante = RTRIM(@SistemaErogante)
			SET @RepartoErogante = NULLIF(RTRIM(@RepartoErogante),'')	--modifica per gestione NULL
			
			SET @NumeroNosologico = RTRIM(@NumeroNosologico)			--NUOVO: modifica per gestione NULL
			SET @RepartoCodice = NULLIF(RTRIM(@RepartoCodice),'')		--NUOVO: modifica per gestione NULL
			SET @RepartoDescr = NULLIF(RTRIM(@RepartoDescr),'')			--NUOVO: modifica per gestione NULL
			SET @TipoEpisodio = NULLIF(RTRIM(@TipoEpisodio),'')			--NUOVO: modifica per gestione NULL
			SET @Diagnosi = NULLIF(RTRIM(@Diagnosi),'')					--NUOVO: modifica per gestione NULL

			BEGIN TRANSACTION
		------------------------------------------------------
		--  Aggiorno EventiBase
		------------------------------------------------------	

			UPDATE  store.EventiBase
			SET	IdPaziente=@IdPaziente,
				DataModifica=GetDate(),
				AziendaErogante=@AziendaErogante,
				SistemaErogante=@SistemaErogante,
				RepartoErogante=@RepartoErogante,
				DataEvento=@DataEvento,
				TipoEventoCodice = @TipoEventoCodice,
				TipoEventoDescr = @TipoEventoDescr, 
				NumeroNosologico = @NumeroNosologico,
				TipoEpisodio = @TipoEpisodio,
				RepartoCodice = @RepartoCodice,
				RepartoDescr = @RepartoDescr,
				Diagnosi = @Diagnosi
			WHERE 
				Id=@guidId

			SET @NumRecord = @@ROWCOUNT
			IF @NumRecord = 0 GOTO ERROR_EXIT
		
			SET NOCOUNT ON
	
		------------------------------------------------------------------------------------------------------------
		--  		Reparti richiedenti
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
				--  Nuovo
				--
				INSERT INTO dbo.RepartiRichiedentiSistemiEroganti
					(IdSistemaErogante, RepartoRichiedenteCodice, RepartoRichiedenteDescrizione)
				SELECT Id, RTRIM(@RepartoCodice), RTRIM(@RepartoDescr)
				FROM dbo.SistemiEroganti
				WHERE AziendaErogante = RTRIM(@AziendaErogante)
					AND SistemaErogante = RTRIM(@SistemaErogante)
			ELSE
				--
				--  Aggiorno 
				--
				UPDATE dbo.RepartiRichiedentiSistemiEroganti
				SET RepartoRichiedenteDescrizione = RTRIM(@RepartoDescr)
				WHERE Id = @IdReparto
					AND RepartoRichiedenteDescrizione <> RTRIM(@RepartoDescr)

			IF @@ERROR <> 0 GOTO ERROR_EXIT
		END

		------------------------------------------------------------------------------------------------------------
		--  		Eventi Attributi
		------------------------------------------------------------------------------------------------------------	
			--
			-- Ricavo la DataPartizione dell'evento da usare nell'inserimento degli attributi
			--
			--SELECT @DataPartizione = Datapartizione FROM store.EventiBase where Id = @guidId
			
			---------------------------------------------------
			-- Rimuovo tutti gli attributi
			---------------------------------------------------
			DELETE FROM store.EventiAttributi WHERE IdEventiBase=@guidId
			
			IF @@ERROR <> 0 GOTO ERROR_EXIT

			---------------------------------------------------
			--     Attributi già in EventiBase: NESSUNO
			---------------------------------------------------
				
			---------------------------------------------------
			--     Attributi presenti solo in EventiAttributi:
			---------------------------------------------------
			IF LTRIM(RTRIM(@TipoEpisodioDescr))<>'' AND NOT @TipoEpisodioDescr IS NULL
				BEGIN
					INSERT INTO store.EventiAttributi (IdEventiBase, Nome,  Valore, DataPartizione) 
					VALUES (@guidId, 'TipoEpisodioDescr', LTRIM(RTRIM(@TipoEpisodioDescr)), @DataPartizione)

					IF @@ERROR <> 0 GOTO ERROR_EXIT
				END			
			---------------------------------------------------
			--     Altri Attributi: dati anagrafici ecc...
			---------------------------------------------------
			IF DATALENGTH(@XmlAttributi) > 0 AND NOT @XmlAttributi IS NULL 
				BEGIN 
					EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @XmlAttributi

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
		END
	ELSE
		BEGIN
			---------------------------------------------------
			--     Evento non trovato
			---------------------------------------------------
			SELECT INSERTED_COUNT=NULL
			RAISERROR('Errore ''Evento'' non trovato!', 16, 1)
			RETURN 1002
		END	

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	SELECT INSERTED_COUNT=0
	RETURN 1


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtEventiModifica] TO [ExecuteExt]
    AS [dbo];

