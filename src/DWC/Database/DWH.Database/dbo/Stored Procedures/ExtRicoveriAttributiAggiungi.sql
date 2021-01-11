



-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Description:	
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2018-07-13 - ETTORE: Uso della nuova funzione dbo.GetRicoveriPk
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo ai messaggi di errore:
--										"Errore manca almeno un parametro obbligatorio"
--										"Errore Ricovero non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtRicoveriAttributiAggiungi]
(	@IdEsterno 	varchar (64),
	@Nome	varchar (64),
	@Valore	sql_variant
) AS
BEGIN
/* 
	Aggiungo un attributo al ricovero
*/
	DECLARE @guidId					AS UNIQUEIDENTIFIER
	DECLARE @DataPartizione			AS SMALLDATETIME
	DECLARE @DataModificaEsterno	AS DATETIME


	SET NOCOUNT ON

	------------------------------------------------------
	--  Verifica dati
	------------------------------------------------------	

	IF ISNULL(@IdEsterno, '') = '' OR ISNULL(@Nome, '') = '' OR @Valore IS NULL
		BEGIN
		------------------------------------------------------
		--Errore Manca campo obbligatorio
		------------------------------------------------------
		--SELECT INSERTED_COUNT = NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore manca almeno un parametro obbligatorio (@IdEsterno, @Nome, @Valore)!', 16, 1)
		RETURN 1010
		END

	------------------------------------------------------
	--  Cerca IdRicovero
	------------------------------------------------------	
	--SET @guidId = dbo.GetRicoveriId(@IdEsterno)
	-- Legge la PK e DataModificaEsterno
	SELECT 
		@guidId = ID
		, @DataPartizione = DataPartizione
		,@DataModificaEsterno = DataModificaEsterno
	FROM 
		[dbo].[GetRicoveriPk](@IdEsterno)


	IF Not @guidId IS NULL
		BEGIN
			BEGIN TRANSACTION
--
-- Per il db versione partizionata bisognerebbe aggiungere anche la DataRicovero
-- Poichè il record del Ricovero può esistere anche se non è arrivata A (solo E)
-- cosa si usa per la data del ricovero? la si potrebbe ricavare dal NumeroNosologico:
-- il secondo è il terzo carattere (numerici) rappresentano l'anno a 2 cifre
--
			INSERT INTO store.RicoveriAttributi (IdRicoveriBase, Nome,  Valore, DataPartizione) 
			SELECT Id, @Nome, @Valore, DataPartizione FROM store.RicoveriBase WHERE Id=@guidId

			IF @@ERROR <> 0 GOTO ERROR_EXIT

			---------------------------------------------------
			--     Completato
			---------------------------------------------------

			COMMIT
			SELECT INSERTED_COUNT=1
			RETURN 0
		END
	ELSE
		BEGIN
			---------------------------------------------------
			--     Ricovero non trovato
			---------------------------------------------------
			--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
			RAISERROR('Errore Ricovero non trovato!', 16, 1)
			RETURN 1002
		END	

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
    ON OBJECT::[dbo].[ExtRicoveriAttributiAggiungi] TO [ExecuteExt]
    AS [dbo];

