









-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-31
-- Modify date: 2020-02-27 - ETTORE - Aggiornamento tabella "ultimi arrivi" [ASMN 7707]
-- Description:	Aggiunge o Modifica una nota anamnestica usando come chiave @IdEsternoNotaAnamnestica
--				Restituisce l'XML che viene inserito nella coda di output che verrà utilizzato dalle DAE per popolare
--				l'oggetto da restituire all'orchestrazione
-- =============================================
CREATE PROCEDURE [dbo].[ExtNoteAnamnesticheAggiungi](
  @IdEsternoNotaAnamnestica			varchar (64)
, @IdPaziente						uniqueidentifier
, @DataModificaEsterno				datetime
, @StatoCodice						tinyint
, @AziendaErogante					varchar(16)
, @SistemaErogante					varchar(16)
, @DataNota							datetime
, @DataFineValidita					datetime
, @TipoCodice						varchar(16)
, @TipoDescrizione					varchar(256)
, @TipoContenuto					varchar(64)
, @Contenuto						varbinary(MAX)
, @ContenutoHTML					varchar(MAX)
, @ContenutoText					varchar(MAX)
, @Attributi						xml = NULL
---- Ritorna la PK del record inserito
--, @IdNotaAnamnestica				uniqueidentifier = NULL OUTPUT
--, @DataPartizione					smalldatetime = NULL OUTPUT
--, @Azione							varchar(16) = NULL OUTPUT
) AS
BEGIN
/* 
Il campo @XmlAttributi deve avere la seguente struttura:

<AttributiType xmlns="http://schemas.progel.it/BT/DWH/DataAccess/NoteAnamnestiche/1.0">
	<Attributo>
		<Nome>Nome</Nome>
		<Valore>nome01</Valore>
	</Attributo>
</AttributiType>

*/
--
-- Dati restituiti nella select
--
DECLARE @IdNotaAnamnestica	uniqueidentifier 
DECLARE @DataPartizione		smalldatetime
DECLARE @Azione				varchar(16)

DECLARE @Err int
DECLARE @DataModificaEsternoCorrente datetime

DECLARE @ImportazioneStorica varchar(1) --valori 0/1
DECLARE @DataInserimento  datetime
DECLARE @DataModifica  datetime

DECLARE @TableAttributi table (Nome varchar(128), Valore varchar(8000))

	SET NOCOUNT ON

	------------------------------------------------------
	--  Verifica dati
	------------------------------------------------------	
		
	IF ISNULL(@IdEsternoNotaAnamnestica, '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdEsternoNotaAnamnestica)!', 16, 1)
		RETURN 1010
	END

	IF @IdPaziente IS NULL 
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdPaziente)!', 16, 1)
		RETURN 1011
	END

	IF @DataModificaEsterno IS NULL
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		RAISERROR('Errore manca almeno un parametro obbligatorio (@DataModificaEsterno)!', 16, 1)
		RETURN 1012
	END

	IF ISNULL(@TipoCodice, '') = '' 
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		RAISERROR('Errore manca almeno un parametro obbligatorio (@TipoCodice)!', 16, 1)
		RETURN 1013
	END

	IF ISNULL(@TipoDescrizione, '') = '' 
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		RAISERROR('Errore manca almeno un parametro obbligatorio (@TipoDescrizione)!', 16, 1)
		RETURN 1014
	END

	
	IF @DataNota IS NULL
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		RAISERROR('Errore manca almeno un parametro obbligatorio (@DataNota)!', 16, 1)
		RETURN 1015
	END

	IF NOT ISNULL(@StatoCodice, '') IN ('', '0', '1', '2', '3')
	BEGIN
		------------------------------------------------------
		--Errore Stato Richiesta Codice
		------------------------------------------------------
		RAISERROR('Errore parametro @StatoCodice non valido!', 16, 1)
		RETURN 1016
	END

	IF ISNULL(@AziendaErogante, '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		RAISERROR('Errore manca almeno un parametro obbligatorio (@AziendaErogante)!', 16, 1)
		RETURN 1017
	END

	IF ISNULL(@SistemaErogante, '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		RAISERROR('Errore manca almeno un parametro obbligatorio (@SistemaErogante)!', 16, 1)
		RETURN 1018
	END

	IF ISNULL(@TipoContenuto, '') = '' OR (@Contenuto IS NULL) OR ISNULL(@ContenutoHTML, '') = '' OR ISNULL(@ContenutoText, '') = '' 
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		RAISERROR('Errore manca almeno un parametro obbligatorio (@Contenuto, @TipoContenuto, @ContenutoHTML, @ContenutoText)!', 16, 1)
		RETURN 1018
	END

	------------------------------------------------------
	-- Leggo dati attributo "ImportazioneStorica" 
	------------------------------------------------------
	
	IF NOT @Attributi IS NULL
		SELECT @ImportazioneStorica = @Attributi.value('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/NoteAnamnestiche/1.0"; (/s:AttributiType/s:Attributo[s:Nome="ImportazioneStorica"]/s:Valore)[1]', 'varchar(1)')

	SET @ImportazioneStorica = CASE WHEN @ImportazioneStorica IS NULL THEN 0
									WHEN @ImportazioneStorica = 'F' THEN 0
									WHEN @ImportazioneStorica = 'T' THEN 1
									WHEN @ImportazioneStorica = 'N' THEN 0
									WHEN @ImportazioneStorica = 'S' THEN 1
									WHEN @ImportazioneStorica = '0' THEN 0
									WHEN @ImportazioneStorica = '1' THEN 1
									ELSE 0 END

	IF @ImportazioneStorica = '1' 
	BEGIN
		SET @DataInserimento = @DataNota
		SET @DataModifica = @DataNota
	END ELSE BEGIN
		SET @DataInserimento = GETDATE()
		SET @DataModifica = GETDATE()
	END

------------------------------------------------------------------------------------------------------------
--  Dati da PARAMETRI e CALCOLATI salvati come Attributi
------------------------------------------------------------------------------------------------------------	
	
	--
	-- Lasciata come template per future estensioni
	--
	--INSERT INTO @TableAttributi (Nome, Valore)
	--	VALUES ('StatoDescrizione', CASE @StatoCodice WHEN 0 THEN 'In corso'
	--														WHEN 1 THEN 'Completata'
	--														WHEN 2 THEN 'Annullata'
	--														WHEN 3 THEN 'Variata'
	--														END)
	--IF @@ERROR <> 0 GOTO ERROR_EXIT
	
	------------------------------------------------------
	-- Appendo gli attributi PARAMETRO XML se non vuoto
	------------------------------------------------------

	IF @Attributi IS NOT NULL
	BEGIN
		INSERT INTO @TableAttributi (Nome, Valore)
		SELECT	Attributo.Col.value('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/NoteAnamnestiche/1.0"; s:Nome[1]','varchar(128)') AS Nome,
				Attributo.Col.value('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/NoteAnamnestiche/1.0"; s:Valore[1]','varchar(MAX)') AS Valore
			FROM @Attributi.nodes('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/NoteAnamnestiche/1.0"; /s:AttributiType/s:Attributo') Attributo(Col)
	
		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

    ------------------------------------------------------
	--  Rimuovo attributi con valore vuoto
	------------------------------------------------------	

	IF EXISTS (SELECT * FROM @TableAttributi)
	BEGIN
		DELETE FROM @TableAttributi
		WHERE CONVERT(BINARY(2), Valore) = 0x0000

		IF @@ERROR <> 0 GOTO ERROR_EXIT
	END

	------------------------------------------------------
	--  Cerco se esiste gia IdEsterno
	------------------------------------------------------	

	-- Legge la PK e DataModifica della nota anamnestica
	SELECT @IdNotaAnamnestica = ID, @DataPartizione = DataPartizione
			,@DataModificaEsternoCorrente = DataModificaEsterno
		FROM [dbo].[GetNoteAnamnestichePk](RTRIM(@IdEsternoNotaAnamnestica))

	BEGIN TRANSACTION
	
	------------------------------------------------------
	--  		NoteAnamnestiche Base
	------------------------------------------------------	

	IF NOT @IdNotaAnamnestica IS NULL AND NOT @DataModificaEsternoCorrente IS NULL
		AND NOT @DataModificaEsterno IS NULL
		AND	@DataModificaEsternoCorrente > @DataModificaEsterno
	BEGIN
		----------------------------------------
		--la nota anamnestica è più recente, non aggiorno
	
		SET @Azione = NULL
		SET @Err = 0
	
	END ELSE IF @IdNotaAnamnestica IS NULL 
	BEGIN
		----------------------------------------
		--Aggiungo la nota anamnestica
		SET @IdNotaAnamnestica = NEWID()
		SET @DataPartizione = CONVERT(SMALLDATETIME, @DataNota)
		SET @Azione = 'INSERT'		

		INSERT INTO [store].[NoteAnamnesticheBase]
			([Id]
			,[DataPartizione]
			,[IdEsterno]
			,[IdPaziente]
			,[DataInserimento]
			,[DataModifica]
			,[DataModificaEsterno]
			,[StatoCodice]
			,[AziendaErogante]
			,[SistemaErogante]
			,[DataNota]
			,[DataFineValidita]
			,[TipoCodice]
			,[TipoDescrizione]
			,[Contenuto]
			,[TipoContenuto]
			,[ContenutoHtml]
			,[ContenutoText]
			)
		 VALUES
			(@IdNotaAnamnestica
			,@DataPartizione
			,@IdEsternoNotaAnamnestica
			,@IdPaziente
			,@DataInserimento
			,@DataModifica
			,ISNULL(@DataModificaEsterno, GETUTCDATE())
			,@StatoCodice
			,@AziendaErogante
			,@SistemaErogante
			,@DataNota
			,@DataFineValidita
			,@TipoCodice
			,@TipoDescrizione
			,@Contenuto
			,@TipoContenuto
			,@ContenutoHtml
			,@ContenutoText
			)

		SELECT @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

	END ELSE BEGIN
		----------------------------------------
		--Modifico la nota anmnestica
		SET @Azione = 'UPDATE'

		UPDATE [store].[NoteAnamnesticheBase]
		   SET [IdPaziente] = @IdPaziente
			  ,[DataModifica] = @DataModifica
			  ,[DataModificaEsterno] = ISNULL(@DataModificaEsterno, GETUTCDATE())
			  ,[StatoCodice] = @StatoCodice
				,[AziendaErogante] = @AziendaErogante
				,[SistemaErogante] = @SistemaErogante
				,[DataNota] = @DataNota
				,[DataFineValidita] = @DataFineValidita
				,[TipoCodice] = @TipoCodice
				,[TipoDescrizione] = @TipoDescrizione
				,[Contenuto] = @Contenuto
				,[TipoContenuto] = @TipoContenuto
				,[ContenutoHtml] = @ContenutoHtml
				,[ContenutoText] = @ContenutoText

		 WHERE [Id] = @IdNotaAnamnestica
			  AND [DataPartizione] = @DataPartizione
			  AND [IdEsterno] = @IdEsternoNotaAnamnestica
			  AND [DataModificaEsterno] <= @DataModificaEsterno

		SELECT @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT
	END

	---------------------------------------------------
	--     Attributi, rimuovo e reinserisco
	---------------------------------------------------
	DELETE FROM [store].[NoteAnamnesticheAttributi]
	WHERE [IdNoteAnamnesticheBase] = @IdNotaAnamnestica
			  AND [DataPartizione] = @DataPartizione

	SELECT @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	-- Se ci sono attributi li reinserisco
	IF EXISTS (SELECT * FROM @TableAttributi)
		BEGIN
			-- Inserico nella tabella Attributi concatenando quello uguali di Nome
			INSERT INTO [store].[NoteAnamnesticheAttributi]
						   ([IdNoteAnamnesticheBase]
						   ,[DataPartizione]
						   ,[Nome]
						   ,[Valore])
				SELECT @IdNotaAnamnestica AS [Id]
					  ,@DataPartizione AS [DataPartizione]
					  ,[Nome]
					  , CASE WHEN COUNT(*) > 1 THEN
									-- Se multiplo concateno
									CONVERT(VARCHAR(8000), 
										SUBSTRING((SELECT '; ' + [Valore] AS 'data()' FROM @TableAttributi a
													WHERE a.[Nome]=Attributi.[Nome]
														AND NOT NULLIF(a.[Valore], '') IS NULL
													FOR XML PATH('')), 3, 8000)
											)
									-- Unico valore
							ELSE MIN([Valore]) END AS [Valore]

				FROM @TableAttributi Attributi
				GROUP BY [Nome]

			SELECT @Err = @@ERROR
			IF @Err <> 0 GOTO ERROR_EXIT
		END

	---------------------------------------------------
	--     Completato
	---------------------------------------------------

	-- Modify date: 2020-02-27 - ETTORE - Aggiornamento tabella "ultimi arrivi" [ASMN 7707]
	EXECUTE [sinottico].[UltimiArriviNoteAnamnesticheAggiorna] @AziendaErogante, @SistemaErogante

	COMMIT
	--
	-- Restituisco XML
	--
	SELECT 
		@IdNotaAnamnestica	AS IdNotaAnamnestica
		, @DataPartizione	AS DataPartizione
		, @Azione AS Azione	
		, dbo.GetNotaAnamnesticaXml(@IdNotaAnamnestica, @Datapartizione) AS NotaAnamnesticaXML
	--
	-- Il RETURN fa anche saltare le righe sotto
	--
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	IF @@TRANCOUNT > 0
		ROLLBACK
	--
	-- Restituisco XML = NULL
	-- In ogni caso tali dati non verranno usati dalla DAE
	--
	SELECT 
		@IdNotaAnamnestica AS IdNotaAnamnestica
		, @DataPartizione AS DataPartizione
		, @Azione AS DataPartizione
		, CAST(NULL AS XML) AS NotaAnamnesticaXML
	RETURN 1


END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtNoteAnamnesticheAggiungi] TO [ExecuteExt]
    AS [dbo];

