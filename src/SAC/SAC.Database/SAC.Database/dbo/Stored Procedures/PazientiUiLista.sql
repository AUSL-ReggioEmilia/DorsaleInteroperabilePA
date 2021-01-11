

CREATE PROCEDURE [dbo].[PazientiUiLista]
	@Cognome varchar(64) = NULL,
	@Nome varchar(64) = NULL,
	@DataNascita as datetime = NULL,
	@CodiceFiscale as varchar(16) = NULL,
	@Tessera as varchar(16) = NULL

WITH RECOMPILE --Ricalcola sempre il piano di esecuzione

AS
BEGIN
	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT TOP 1000 *

	FROM 
		PazientiUiBaseResult WITH(NOLOCK)
	
	WHERE
		(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
	AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
	AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
	AND (CodiceFiscale = @CodiceFiscale OR @CodiceFiscale IS NULL)
	AND (Tessera = @Tessera OR @Tessera IS NULL)
	AND (Disattivato = 0)
	AND (Occultato = 0)

	ORDER BY Cognome, Nome

END

















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiLista] TO [DataAccessUi]
    AS [dbo];

