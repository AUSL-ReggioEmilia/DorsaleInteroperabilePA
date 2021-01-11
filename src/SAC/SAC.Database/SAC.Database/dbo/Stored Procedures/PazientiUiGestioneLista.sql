

CREATE PROCEDURE [dbo].[PazientiUiGestioneLista]
	@Cognome varchar(64) = NULL,
	@Nome varchar(64) = NULL,
	@DataNascita as datetime = NULL,
	@CodiceFiscale as varchar(16) = NULL,
	@Tessera as varchar(16) = NULL,
	@Disattivato as tinyint = NULL,
	@Occultato as bit = NULL

WITH RECOMPILE --Ricalcola sempre il piano di esecuzione

AS
BEGIN

IF @Disattivato = 255 SET @Disattivato = null

	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT TOP 1000 *

	FROM 
		PazientiUiBaseGestioneResult WITH(NOLOCK)
	
	WHERE
		(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
	AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
	AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
	AND (CodiceFiscale = @CodiceFiscale OR @CodiceFiscale IS NULL)
	AND (Tessera = @Tessera OR @Tessera IS NULL)
	AND (Disattivato = @Disattivato OR @Disattivato IS NULL)
	AND (Occultato = @Occultato OR @Occultato IS NULL)

	ORDER BY Cognome, Nome

END















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiGestioneLista] TO [DataAccessUi]
    AS [dbo];

