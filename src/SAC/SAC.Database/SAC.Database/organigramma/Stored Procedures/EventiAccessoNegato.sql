﻿
CREATE PROCEDURE [organigramma].[EventiAccessoNegato] 
	  @Utente AS varchar(64)
	, @Codice AS int
	, @Oggetto AS varchar(64)
	, @Messaggio AS varchar(1024)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [organigramma].[Eventi] (Utente, Operazione, Codice, Oggetto, Messaggio)
		VALUES (ISNULL(@Utente, SUSER_NAME()), 21, @Codice, @Oggetto, @Messaggio)
END
