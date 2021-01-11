

CREATE PROCEDURE [dbo].[ConsensiEventiSuccesso] 
	  @Utente AS varchar(64)
	, @Codice AS int
	, @Oggetto AS varchar(64)
	, @Messaggio AS varchar(1024)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO ConsensiEventi (Utente, Operazione, Codice, Oggetto, Messaggio)
		VALUES (@Utente, 0, @Codice, @Oggetto, @Messaggio)
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiEventiSuccesso] TO [DataAccessUi]
    AS [dbo];

