


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-03
-- Modify date: 2016-08-10 Sandro: Tabella split data e attributi senza campo XML
--									Usa tabella PrescrizioneBase
-- Description:	Aggiunge o Modifica un allegato della prescrizione
--					usando come chiave @IdEsternoPrescrizione e @IdPrescrizioni
-- =============================================
CREATE PROCEDURE [dbo].[ExtPrescrizioniAllegatiAggiungi](
 @IdPrescrizione		uniqueidentifier
,@DataPartizione		smalldatetime
,@IdEsternoAllegato		varchar (64)
,@TipoContenuto 		varchar (64)
,@Contenuto 			varbinary(max)
,@Attributi		 		xml = NULL
--OUTPUT
,@Azione 			varchar (16) = NULL OUTPUT
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
DECLARE @IdAllegato uniqueidentifier
DECLARE @NumRecord int
DECLARE @Err int

DECLARE @TableAttributi table (Nome varchar(128), Valore varchar(8000))

	SET NOCOUNT ON

	------------------------------------------------------
	-- Verifico che i byte dell'allegato siano presenti
	------------------------------------------------------
	IF ISNULL(DATALENGTH(@Contenuto),0) = 0 
	BEGIN
		------------------------------------------------------
		-- Errore se mancano i dati dell'allegato
		------------------------------------------------------
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore dati allegato mancante!', 16, 1)
		RETURN 1021
	END

	IF NULLIF(@TipoContenuto, '') IS NULL
		BEGIN
			------------------------------------------------------
			--Errore se tipo conenuto è vuoto
			------------------------------------------------------
			SELECT INSERTED_COUNT = NULL
			RAISERROR('Errore il TipoContenuto è vuoto!', 16, 1)
			RETURN 1022
		END

	------------------------------------------------------
	-- Comprime @Allegato e verifica tramite CHECKSUM
	------------------------------------------------------

	DECLARE @ContenutoCompresso AS VARBINARY(MAX)
	SET @ContenutoCompresso = dbo.compress(@Contenuto)

	-- Se non compresso salvo l'originale da riprocessare
	DECLARE @AllegatoChecksum AS INT = 0
	DECLARE @DecompressoChecksum AS INT = 0

	IF @ContenutoCompresso IS NOT NULL 
	BEGIN
		SET @AllegatoChecksum = CHECKSUM(@Contenuto)
		SET @DecompressoChecksum = CHECKSUM(dbo.decompress(@ContenutoCompresso))

		-- Verifica risultato compressione 
		IF @AllegatoChecksum != @DecompressoChecksum
		BEGIN
			------------------------------------------------------
			--Errore se no Prescrizioni
			------------------------------------------------------
			SELECT INSERTED_COUNT = NULL
			RAISERROR('Errore di CHECKSUM verifica compresisone!', 16, 1)
			RETURN 1002
		END
	END

	------------------------------------------------------
	-- Appendo gli attributi PARAMETRO XML se non vuoto
	------------------------------------------------------

	IF @Attributi IS NOT NULL
	BEGIN
		INSERT INTO @TableAttributi (Nome, Valore)
		SELECT	Attributo.Col.value('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"; s:Nome[1]','varchar(128)') AS Nome,
				Attributo.Col.value('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"; s:Valore[1]','varchar(MAX)') AS Valore
			FROM @Attributi.nodes('declare namespace s="http://schemas.progel.it/BT/DWH/DataAccess/Prescrizioni/1.0"; /s:AttributiType/s:Attributo') Attributo(Col)
	END
	---
	--- Aggiunge allegato
	---
	BEGIN TRANSACTION
	
	SET @IdAllegato = NULL
	SELECT @IdAllegato = [ID]
			FROM [store].[PrescrizioniAllegati]
			WHERE [IdPrescrizioniBase] = @IdPrescrizione
				AND [IdEsterno] = @IdEsternoAllegato
				AND [DataPartizione] = @DataPartizione
	
	IF NOT @IdAllegato IS NULL
	BEGIN
		-- Modifico allegato
		UPDATE [store].[PrescrizioniAllegatiBase]
		SET [DataModifica] = GETDATE()
			, [TipoContenuto] = @TipoContenuto
			, [ContenutoCompresso] = @ContenutoCompresso
		WHERE [ID] = @IdAllegato

		SET @Azione = 'UPDATE'

	END ELSE BEGIN
		-- Nuovo allegato
		SET @IdAllegato = NEWID() 

		INSERT INTO [store].[PrescrizioniAllegatiBase]
		(
			[ID], [DataPartizione], [IdPrescrizioniBase], [IdEsterno]
			, [DataInserimento], [DataModifica], [TipoContenuto], [ContenutoCompresso]
		)
		VALUES
		(
			@IdAllegato, @DataPartizione, @IdPrescrizione, @IdEsternoAllegato
			, GETDATE(), GETDATE(), @TipoContenuto, @ContenutoCompresso
		)

		SET @Azione = 'INSERT'
	END

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT


	---------------------------------------------------
	--     Attributi, rimuovo e reinserisco
	---------------------------------------------------
	
	DELETE FROM [store].[PrescrizioniAllegatiAttributi]
	WHERE [IdPrescrizioniAllegatiBase] = @IdAllegato
			  AND [DataPartizione] = @DataPartizione

	SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
	IF @Err <> 0 GOTO ERROR_EXIT

	-- Se ci sono attributi li reinserisco
	IF EXISTS (SELECT * FROM @TableAttributi)
		BEGIN
			-- Inserico nella tabella Attributi concatenando quello uguali di Nome
			INSERT INTO [store].[PrescrizioniAllegatiAttributi]
						   ([IdPrescrizioniAllegatiBase]
						   ,[DataPartizione]
						   ,[Nome]
						   ,[Valore])
				SELECT @IdAllegato AS [IdPrescrizioniAllegatiBase]
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

	---------------------------------------------------
	--     Completato
	---------------------------------------------------

	COMMIT
	SELECT INSERTED_COUNT = @NumRecord
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	IF @@TRANCOUNT > 0
		ROLLBACK

	SELECT INSERTED_COUNT = 0
	RETURN 1
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtPrescrizioniAllegatiAggiungi] TO [ExecuteExt]
    AS [dbo];

