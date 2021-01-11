

CREATE PROCEDURE [dbo].[PazientiAccessiLogAdd] 
	  @Utente AS varchar(64)
	, @Operazione AS tinyint
	, @Oggetto AS varchar(64)
	, @Messaggio AS varchar(1024)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO PazientiEventi (Utente, Operazione, Oggetto, Messaggio)
		VALUES (@Utente, @Operazione, @Oggetto, @Messaggio)
END


