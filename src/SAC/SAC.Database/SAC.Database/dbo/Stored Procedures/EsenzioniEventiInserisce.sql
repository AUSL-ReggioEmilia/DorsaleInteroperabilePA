

-- =============================================
-- Author:		SimoneB
-- Create date: 2018-04-24
-- Description:	Scrive un record dentro dbo.EsenzioniEventi per tracciare tutti gli eventi delle esenzioni.
-- =============================================
CREATE PROCEDURE [dbo].[EsenzioniEventiInserisce] 
	  @Utente AS varchar(64)
	, @Codice AS int
	, @OperazioneDescrizione AS VARCHAR(32)
	, @Oggetto AS varchar(64)
	, @Messaggio AS varchar(1024)
AS
BEGIN
	SET NOCOUNT ON;

	--DICHIARO UNA VARIABILE PER IL CODICE DELL'OPERAZIONE
	DECLARE @CodiceOperazione AS TINYINT 
	
	SELECT @CodiceOperazione = Id
	FROM dbo.EventiOperazione
	WHERE Descrizione = @OperazioneDescrizione

	IF @CodiceOperazione IS NULL
		BEGIN 
			--RESTITUISCO UN ERRORE
			RAISERROR('Errore [dbo].[EsenzioniEventiInserisce]: @CodiceOperazione non trovato.', 16, 1)
		END

	INSERT INTO dbo.EsenzioniEventi(Utente, Operazione, Codice, Oggetto, Messaggio)
		VALUES (@Utente, @CodiceOperazione, @Codice, @Oggetto, @Messaggio)
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[EsenzioniEventiInserisce] TO [DataAccessUi]
    AS [dbo];

