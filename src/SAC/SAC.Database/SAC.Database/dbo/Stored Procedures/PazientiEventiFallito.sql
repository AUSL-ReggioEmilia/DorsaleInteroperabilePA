﻿

CREATE PROCEDURE [dbo].[PazientiEventiFallito] 
	  @Utente AS varchar(64)
	, @Codice AS int
	, @Oggetto AS varchar(64)
	, @Messaggio AS varchar(1024)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO PazientiEventi (Utente, Operazione, Codice, Oggetto, Messaggio)
		VALUES (@Utente, 1, @Codice, @Oggetto, @Messaggio)
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiEventiFallito] TO [DataAccessUi]
    AS [dbo];

