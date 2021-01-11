

CREATE PROCEDURE [dbo].[PazientiEventiErrore] 
	  @Utente AS varchar(64)
	, @Codice AS int
	, @Oggetto AS varchar(64)
	, @Messaggio AS varchar(1024)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO PazientiEventi (Utente, Operazione, Codice, Oggetto, Messaggio)
		VALUES (@Utente, 12, @Codice, @Oggetto, @Messaggio)
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiEventiErrore] TO [DataAccessUi]
    AS [dbo];

