

-- =============================================
-- Author:		Pichierri
-- Create date: ???
-- Description:	Aggiunge le esenzioni di un paziente
-- Modify date: 2018-05-28 - ETTORE: gestione delle esenzioni per PROVENIENZA dell'@Utente
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgEsenzioniAdd]
	( @Utente varchar(64)
	, @IdProvenienza varchar(64)
	
	, @CodiceEsenzione varchar(32)
	, @CodiceDiagnosi varchar(32)
	, @Patologica bit
	, @DataInizioValidita datetime
	, @DataFineValidita datetime
	, @NumeroAutorizzazioneEsenzione varchar(64)
	, @NoteAggiuntive varchar(2048)
	, @CodiceTestoEsenzione varchar(64)
	, @TestoEsenzione varchar(2048)
	, @DecodificaEsenzioneDiagnosi varchar(1024)
	, @AttributoEsenzioneDiagnosi varchar(1024)
	)
AS
BEGIN

DECLARE @IdPaziente AS uniqueidentifier
DECLARE @Provenienza AS varchar(16)

DECLARE @DataInserimento AS datetime
DECLARE @Id AS uniqueidentifier

DECLARE @RowCount AS integer

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Cerco Id del paziente
	---------------------------------------------------

	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante [PazientiMsgEsenzioniAdd]!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	SET @IdPaziente = dbo.GetPazienteIdByProvenienza(@Provenienza, @IdProvenienza)
	IF @IdPaziente IS NULL
	BEGIN
		RAISERROR('Errore di Paziente non trovato durante [PazientiMsgEsenzioniAdd]!', 16, 1)
		SELECT 2002 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	SET @DataInserimento = GetDate()
	SET @Id = NewId()
	
	SET NOCOUNT OFF;

	INSERT INTO PazientiEsenzioni
		( Id
		, IdPaziente
		, DataInserimento
		, DataModifica

		, CodiceEsenzione
		, CodiceDiagnosi
		, Patologica
		, DataInizioValidita
		, DataFineValidita
		, NumeroAutorizzazioneEsenzione
		, NoteAggiuntive
		, CodiceTestoEsenzione
		, TestoEsenzione
		, DecodificaEsenzioneDiagnosi
		, AttributoEsenzioneDiagnosi
		-- 2018-05-28 - ETTORE: gestione delle esenzioni per PROVENIENZA dell'@Utente
		, Provenienza
		)
	VALUES
		( @Id
		, @IdPaziente
		, @DataInserimento
		, @DataInserimento	--DataModifica

		, @CodiceEsenzione
		, @CodiceDiagnosi
		, @Patologica
		, @DataInizioValidita
		, @DataFineValidita
		, @NumeroAutorizzazioneEsenzione
		, @NoteAggiuntive
		, @CodiceTestoEsenzione
		, @TestoEsenzione
		, @DecodificaEsenzioneDiagnosi
		, @AttributoEsenzioneDiagnosi
		-- 2018-05-28 - ETTORE: gestione delle esenzioni per PROVENIENZA dell'@Utente
		, @Provenienza
		)

	SET @RowCount = @@ROWCOUNT
	IF @RowCount = 0
		BEGIN
			RAISERROR('Errore di nessun record aggiunto durante [PazientiMsgEsenzioniAdd]!', 16, 1)
			SELECT 2002 AS ERROR_CODE
			GOTO ERROR_EXIT
		END

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Completato
	---------------------------------------------------

	SELECT @RowCount AS ROW_COUNT
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	RETURN 1

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgEsenzioniAdd] TO [DataAccessDll]
    AS [dbo];

