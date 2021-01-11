/* 
Aggiunge alla tabella RefertiBaseRiferimenti gli idEsterni con cui il medesimo referto 
	può essere identificato

MODIFICATO SANDRO 2015-11-02: Rimosso GetRefertiIsStorico()
								Usa GetRefertiPk()
								Nella JOIN anche DataPartizione
								Usa la VIEW [Store]

*/
CREATE PROCEDURE [dbo].[ExtRefertiRiferimentiAggiungi] 
(	
  @IdEsterno	varchar (64)
, @IdEsternoPrecedente varchar (64)
, @DataModificaEsterno DateTime
) AS
BEGIN

DECLARE @IdRefertiBase uniqueidentifier
DECLARE @DataPartizione  SmallDatetime
DECLARE @NumRecord int
DECLARE @Errore int

	SET NOCOUNT ON
	--
	--  Verifico i parametri
	--
	IF ISNULL(@IdEsterno, '') = ''
	BEGIN
		--
		-- Errore Manca campo obbligatorio
		--
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca il parametro obbligatorio @IdEsterno!', 16, 1)
		RETURN 1010
	END

	IF @DataModificaEsterno IS NULL
	BEGIN
		--
		-- Errore Manca campo obbligatorio
		--
		SELECT INSERTED_COUNT = NULL
		RAISERROR('Errore manca il parametro obbligatorio @DataModificaEsterno!', 16, 1)
		RETURN 1010
	END
	--
	-- Se manca l'IdEsternoVecchio non devo fare nulla
	-- 
	IF ISNULL(@IdEsternoPrecedente ,'') = '' 
	BEGIN
		SELECT INSERTED_COUNT=1
		RETURN 0
	END
	--
	-- Cerco il guid del referto associato all'IdEsternoVecchio
	--
	-- Legge la PK del referto
	SELECT @IdRefertiBase = ID, @DataPartizione = DataPartizione
		FROM [dbo].[GetRefertiPk](RTRIM(@IdEsternoPrecedente))

	IF NOT @IdRefertiBase IS NULL
	BEGIN
		--
		--  Inserimento in RefertiBaseRiferimenti: aggiungo il record solo se non è già presente
		--  un record con lo stesso @IdEsterno = @IdEsternoNuovo
		--
		IF NOT EXISTS(SELECT * FROM [store].RefertiBaseRiferimenti WHERE IdEsterno = @IdEsterno)
		BEGIN 
			INSERT INTO [store].RefertiBaseRiferimenti
				(Id, DataPartizione, IdRefertiBase, IdEsterno, DataInserimento, DataModificaEsterno)
			VALUES
				(NEWID(), @DataPartizione, @IdRefertiBase, @IdEsterno, GETDATE(), @DataModificaEsterno)
		END 

		SELECT @NumRecord = @@ROWCOUNT, @Errore = @@ERROR
		IF @Errore <> 0 GOTO ERROR_EXIT
	END

	---------------------------------------------------
	--     Completato
	---------------------------------------------------
	SELECT INSERTED_COUNT = @NumRecord
	RETURN 0	

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	SELECT INSERTED_COUNT = 0
	RETURN 1
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiRiferimentiAggiungi] TO [ExecuteExt]
    AS [dbo];

