
CREATE PROCEDURE [dbo].[PazientiMsgBaseSelectAllByGeneralita] (
	  @Id uniqueidentifier
	, @Cognome varchar(64)
	, @Nome varchar(64)
	, @DataNascita datetime
	, @CodiceFiscale varchar(16)
	, @Sesso varchar(1)
	, @Top int
	, @SortOrder int
	) WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SET ROWCOUNT @Top

	SELECT 
		  Id
		, Provenienza
		, IdProvenienza
		, Tessera
		, Cognome
		, Nome
		, DataNascita
		, Sesso
		, CodiceFiscale
		, ComuneNascitaCodice
		, ComuneNascitaNome
		, NazionalitaCodice
		, NazionalitaNome
		, IndirizzoRes
		, LocalitaRes
		, CapRes
		, ComuneResCodice
		, ComuneResNome
		, IndirizzoDom
		, LocalitaDom
		, CapDom
		, ComuneDomCodice
		, ComuneDomNome
		, Telefono1
		, Telefono2

	FROM 
		PazientiAttiviMsgBaseResult

	WHERE 
			((Id = @Id) OR (@Id IS NULL))
		AND ((Cognome Like @Cognome + '%') OR (@Cognome IS NULL))
		AND ((Nome Like @Nome + '%') OR (@Nome IS NULL))
		AND ((DataNascita = @DataNascita) OR (@DataNascita IS NULL))
		AND ((CodiceFiscale = @CodiceFiscale) OR (@CodiceFiscale IS NULL))
		AND ((Sesso = @Sesso) OR (@Sesso IS NULL))

	ORDER BY CASE WHEN @SortOrder = 1 THEN Cognome
				  WHEN @SortOrder = 2 THEN Nome
				  --WHEN @SortOrder = 3 THEN DataNascita
				  WHEN @SortOrder = 4 THEN CodiceFiscale
				  WHEN @SortOrder = 5 THEN Sesso
				  ELSE Cognome
			 END

END;




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgBaseSelectAllByGeneralita] TO [DataAccessDll]
    AS [dbo];

