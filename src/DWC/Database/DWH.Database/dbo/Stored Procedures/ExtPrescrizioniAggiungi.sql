



-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-03
-- Modify date: 2016-08-10 Sandro: Tabella split data e attributi senza campo XML
--									Usa tabella PrescrizioneBase
-- Modify date: 2016-08-10 Sandro: Rimosso attributo StatoDescrizione
--									Filtrati attributi vuoti
-- Modify date: 2020-02-27 - ETTORE - Aggiornamento tabella "ultimi arrivi" [ASMN 7707]
--
-- Description:	Aggiunge o Modifica una prescrizione 
--					usando come chiave @IdEsternoPrescrizione
-- =============================================
CREATE PROCEDURE [dbo].[ExtPrescrizioniAggiungi](
  @IdEsternoPrescrizione			varchar (64)
, @IdPaziente						uniqueidentifier
, @DataModificaEsterno				datetime
, @StatoCodice						tinyint
, @TipoPrescrizione					varchar(32)
, @DataPrescrizione					datetime
, @NumeroPrescrizione				varchar(16)
, @MedicoPrescrittoreCodiceFiscale	varchar(16)
, @QuesitoDiagnostico				varchar(2048)
, @Attributi						xml = NULL
-- Ritorna la PK del record inserito
, @IdPrescrizione					uniqueidentifier = NULL OUTPUT
, @DataPartizione					smalldatetime = NULL OUTPUT
, @Azione							varchar(16) = NULL OUTPUT
) AS
BEGIN
/* 
Il campo @XmlAttributi deve avere la seguente struttura:

<AttributiType xmlns="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0">
	<Attributo>
		<Nome>Nome</Nome>
		<Valore>nome01</Valore>
	</Attributo>
</AttributiType>

*/
DECLARE @NumRecord int
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
		
	IF ISNULL(@IdEsternoPrescrizione, '') = ''
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdEsterno)!', 16, 1)
		RETURN 1010
	END

	IF @IdPaziente IS NULL 
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdPaziente)!', 16, 1)
		RETURN 1011
	END

	IF @DataModificaEsterno IS NULL
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@DataModificaEsterno)!', 16, 1)
		RETURN 1012
	END

	IF ISNULL(@TipoPrescrizione, '') = '' 
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@TipoPrescrizione)!', 16, 1)
		RETURN 1013
	END
	
	IF @DataPrescrizione IS NULL
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@DataPrescrizione)!', 16, 1)
		RETURN 1014
	END

	IF NOT ISNULL(@StatoCodice, '') IN ('', '0', '1', '2', '3')
	BEGIN
		------------------------------------------------------
		--Errore Stato Richiesta Codice
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore parametro @StatoCodice non valido!', 16, 1)
		RETURN 1015
	END

	--Il numero di prescrizione può essere vuoto ''
	IF @NumeroPrescrizione IS NULL
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore il parametro @NumeroPrescrizione non può essere NULL!', 16, 1)		
		RETURN 1016
	END

	IF ISNULL(@MedicoPrescrittoreCodiceFiscale, '') = '' 
	BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca almeno un parametro obbligatorio (@MedicoPrescrittoreCodiceFiscale)!', 16, 1)
		RETURN 1017
	END

	------------------------------------------------------
	-- Leggo dati attributo "ImportazioneStorica" 
	------------------------------------------------------
	
	IF NOT @Attributi IS NULL
		SELECT @ImportazioneStorica = @Attributi.value('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"; (/s:AttributiType/s:Attributo[s:Nome="ImportazioneStorica"]/s:Valore)[1]', 'varchar(1)')

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
		SET @DataInserimento = @DataPrescrizione
		SET @DataModifica = @DataPrescrizione
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
		SELECT	Attributo.Col.value('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"; s:Nome[1]','varchar(128)') AS Nome,
				Attributo.Col.value('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"; s:Valore[1]','varchar(MAX)') AS Valore
			FROM @Attributi.nodes('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"; /s:AttributiType/s:Attributo') Attributo(Col)
	
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

	-- Legge la PK e DataModifica della Prescrizione
	SELECT @IdPrescrizione = ID, @DataPartizione = DataPartizione
			,@DataModificaEsternoCorrente = DataModificaEsterno
		FROM [dbo].[GetPrescrizioniPk](RTRIM(@IdEsternoPrescrizione))

	BEGIN TRANSACTION
	
	------------------------------------------------------
	--  		Prescrizioni Base
	------------------------------------------------------	

	IF NOT @IdPrescrizione IS NULL AND NOT @DataModificaEsternoCorrente IS NULL
		AND NOT @DataModificaEsterno IS NULL
		AND	@DataModificaEsternoCorrente > @DataModificaEsterno
	BEGIN
		----------------------------------------
		--la prescrizione e più recente, non aggiorno
	
		SET @Azione = NULL
		SET @NumRecord = 0
		SET @Err = 0
	
	END ELSE IF @IdPrescrizione IS NULL 
	BEGIN
		----------------------------------------
		--Aggiungo la prescrizione
		SET @IdPrescrizione = NEWID()
		SET @DataPartizione = CONVERT(SMALLDATETIME, @DataPrescrizione)
		SET @Azione = 'INSERT'		

		INSERT INTO [store].[PrescrizioniBase]
			   ([Id]
			   ,[DataPartizione]
			   ,[IdEsterno]
			   ,[IdPaziente]
			   ,[DataInserimento]
			   ,[DataModifica]
			   ,[DataModificaEsterno]
			   ,[StatoCodice]
			   ,[TipoPrescrizione]
			   ,[DataPrescrizione]
			   ,[NumeroPrescrizione]
			   ,[MedicoPrescrittoreCodiceFiscale]
			   ,[QuesitoDiagnostico])
		 VALUES
			   (@IdPrescrizione
			   ,@DataPartizione
			   ,@IdEsternoPrescrizione
			   ,@IdPaziente
			   ,@DataInserimento
			   ,@DataModifica
			   ,ISNULL(@DataModificaEsterno, GETUTCDATE())
			   ,@StatoCodice
			   ,@TipoPrescrizione
			   ,@DataPrescrizione
			   ,@NumeroPrescrizione
			   ,@MedicoPrescrittoreCodiceFiscale
			   ,@QuesitoDiagnostico)

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

	END ELSE BEGIN
		----------------------------------------
		--Modifico la prescrizione
		SET @Azione = 'UPDATE'

		UPDATE [store].[PrescrizioniBase]
		   SET [IdPaziente] = @IdPaziente
			  ,[DataModifica] = @DataModifica
			  ,[DataModificaEsterno] = ISNULL(@DataModificaEsterno, GETUTCDATE())
			  ,[StatoCodice] = @StatoCodice
			  ,[TipoPrescrizione] = @TipoPrescrizione
			  ,[DataPrescrizione] = @DataPrescrizione
			  ,[NumeroPrescrizione] = @NumeroPrescrizione
			  ,[MedicoPrescrittoreCodiceFiscale] = @MedicoPrescrittoreCodiceFiscale
  			  ,[QuesitoDiagnostico] = @QuesitoDiagnostico
		 WHERE [Id] = @IdPrescrizione
			  AND [DataPartizione] = @DataPartizione
			  AND [IdEsterno] = @IdEsternoPrescrizione
			  AND [DataModificaEsterno] <= @DataModificaEsterno

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT
	END

	---------------------------------------------------
	--     Attributi, rimuovo e reinserisco
	---------------------------------------------------
	
	DELETE FROM [store].[PrescrizioniAttributi]
	WHERE [IdPrescrizioniBase] = @IdPrescrizione
			  AND [DataPartizione] = @DataPartizione

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	-- Se ci sono attributi li reinserisco
	IF EXISTS (SELECT * FROM @TableAttributi)
	BEGIN
			-- Inserico nella tabella Attributi concatenando quello uguali di Nome
			INSERT INTO [store].[PrescrizioniAttributi]
						   ([IdPrescrizioniBase]
						   ,[DataPartizione]
						   ,[Nome]
						   ,[Valore])
				SELECT @IdPrescrizione AS [Id]
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

			SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
			IF @Err <> 0 GOTO ERROR_EXIT
	END
		
	-- Modify date: 2020-02-27 - ETTORE - Aggiornamento tabella "ultimi arrivi" [ASMN 7707]
	EXECUTE [sinottico].[UltimiArriviPrescrizioniAggiorna] @TipoPrescrizione
	---------------------------------------------------
	--     Completato
	---------------------------------------------------

	COMMIT

	-- Ritorna l'azione eseguita
	SELECT INSERTED_COUNT = @NumRecord
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	IF @@TRANCOUNT > 0
		ROLLBACK
	
	-- Ritorna vuoto, solo la scrittura
	SELECT INSERTED_COUNT = 0
	RETURN 1
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtPrescrizioniAggiungi] TO [ExecuteExt]
    AS [dbo];

