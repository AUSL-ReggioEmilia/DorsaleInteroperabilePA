


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2018-07-13 - ETTORE: Uso della nuova funzione dbo.GetRicoveriPk
-- Description:	Rimuove il Ricovero e suoi attributi
-- =============================================
CREATE PROCEDURE [dbo].[ExtRicoveriRimuovi]
(
	@IdEsterno  varchar(64)
)
AS
	DECLARE @IdRicoveriBase	AS UNIQUEIDENTIFIER
	DECLARE @DataPartizione	AS SMALLDATETIME
	DECLARE @NumRecord		INT

	SET NOCOUNT ON

	--------------------------------------------------------------------------------------------------------
	--- Cerca IdRicovero
	--------------------------------------------------------------------------------------------------------
	--SET @IdRicoveriBase = dbo.GetRicoveriId(@IdEsterno)
	-- Legge la PK e DataModificaEsterno
	SELECT 
		@IdRicoveriBase = ID
		, @DataPartizione = DataPartizione
	FROM 
		[dbo].[GetRicoveriPk](@IdEsterno)

	IF @IdRicoveriBase IS NULL
		BEGIN
		--------------------------------------------------------------------------------------------------------
		--- Referto non trovato
		--------------------------------------------------------------------------------------------------------
		SELECT DELETED_COUNT=NULL
		RAISERROR('Errore Ricovero non trovato!', 16, 1)
		RETURN 1002
		END

	BEGIN TRANSACTION

	------------------------------------------------------------------------------------------------------------
	--  		Ricoveri Log: NO! il log lo si fa a partire dagli eventi
	------------------------------------------------------------------------------------------------------------	

	------------------------------------------------------------------------------------------------------------
	--          Rimuovo attributi
	------------------------------------------------------------------------------------------------------------	
	DELETE FROM  store.RicoveriAttributi
	WHERE  IdRicoveriBase=@IdRicoveriBase
	IF @@ERROR <> 0 GOTO ERROR_EXIT

	------------------------------------------------------------------------------------------------------------
	--          Rimuovo base
	------------------------------------------------------------------------------------------------------------	

	SELECT @NumRecord=COUNT(*) FROM store.RicoveriBase
	WHERE Id=@IdRicoveriBase

	DELETE FROM store.RicoveriBase
	WHERE Id=@IdRicoveriBase

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	--     Completato
	---------------------------------------------------

	COMMIT
	SELECT DELETED_COUNT=@NumRecord
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	SELECT DELETED_COUNT=0
	RETURN 1

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRicoveriRimuovi] TO [ExecuteExt]
    AS [dbo];

