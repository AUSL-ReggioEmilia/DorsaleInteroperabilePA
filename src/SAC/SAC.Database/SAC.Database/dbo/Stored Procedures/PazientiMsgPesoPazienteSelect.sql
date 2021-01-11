

CREATE PROCEDURE [dbo].[PazientiMsgPesoPazienteSelect]
	  @Cognome varchar(64)
	, @Nome varchar(64)
	, @DataNascita datetime
	, @Sesso varchar(1)
	, @ComuneNascitaCodice varchar(6)
	, @Tessera varchar(16)

AS
BEGIN

	SELECT CAST(dbo.GetPesoPaziente(@Cognome, @Nome, @DataNascita, @Sesso, @ComuneNascitaCodice, @Tessera) as int) AS PesoPaziente

END














GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgPesoPazienteSelect] TO [DataAccessDll]
    AS [dbo];

