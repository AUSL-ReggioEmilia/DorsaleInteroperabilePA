
-- =============================================
-- Author:		
-- Create date: 
-- Description:	Aggiunge un attributo al referto
-- Modify date: 2015-11-02 - SANDRO: Rimosso GetRefertiIsStorico()
--								Usa GetPrescrizioniPk()
--								Nella JOIN anche DataPartizione
--								Usa la VIEW [Store]
-- Modify date: 2020-09-16 - ETTORE: Modifica per raise dell'errore relativo ai messaggi di errore:
--									"Errore manca almeno un parametro obbligatorio"		
--									"Errore referto non trovato"
-- =============================================
CREATE PROCEDURE [dbo].[ExtRefertiAttributiAggiungi]
(	@IdEsterno 	varchar (64),
	@Nome	varchar (64),
	@Valore	sql_variant
) AS
BEGIN

DECLARE @IdRefertiBase uniqueidentifier
DECLARE @DataPartizione smalldatetime
DECLARE @NumRecord int
DECLARE @Err int

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
	--  Cerca IdReferto
	------------------------------------------------------
		
	-- Legge la PK del referto
	SELECT @IdRefertiBase = ID, @DataPartizione = DataPartizione
		FROM [dbo].[GetRefertiPk](RTRIM(@IdEsterno))

	IF NOT @IdRefertiBase IS NULL
	BEGIN
		
		BEGIN TRANSACTION

		INSERT INTO [store].RefertiAttributi (IdRefertiBase, Nome,  Valore, DataPartizione) 
		VALUES (@IdRefertiBase, @Nome, @Valore, @DataPartizione)

		SELECT @NumRecord = @@ROWCOUNT, @Err = @@ERROR
		IF @Err <> 0 GOTO ERROR_EXIT

		---------------------------------------------------
		--     Completato
		---------------------------------------------------

		COMMIT
		SELECT INSERTED_COUNT = @NumRecord
		RETURN 0

	END ELSE BEGIN
		---------------------------------------------------
		--     Referto non trovato
		---------------------------------------------------

		--SELECT INSERTED_COUNT=NULL --Ora DAE usa ExecuteScalar per eseguire la SP e se si restituisce qualcosa non viene generata eccezione lato codiceDAE!
		RAISERROR('Errore referto non trovato!', 16, 1)
		RETURN 1001
	END	

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	ROLLBACK
	SELECT INSERTED_COUNT = 0
	RETURN 1
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtRefertiAttributiAggiungi] TO [ExecuteExt]
    AS [dbo];

