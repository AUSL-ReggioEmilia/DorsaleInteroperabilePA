
CREATE PROC [dbo].[PazientiUiAnonimizzazioniPazienteSelect]
(
	@Id UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	Utilizzata per la visualizzazione di dettaglio del paziente da anonimizzare
*/
	SET NOCOUNT OFF
	SELECT Id
		  , ISNULL(Tessera, '') AS Tessera
		  , Cognome
		  , Nome
		  , DataNascita
		  , CodiceFiscale      
		  , Sesso
		  , ComuneNascitaCodice
		  , (SELECT TOP 1 ISNULL(Nome, '') FROM IstatComuni WHERE Codice = P.ComuneNascitaCodice ) AS ComuneNascitaDescrizione
		  , ProvinciaNascitaCodice
		  , (SELECT TOP 1 ISNULL(Nome, '') FROM IstatProvince WHERE Codice = P.ProvinciaNascitaCodice ) AS ProvinciaNascitaDescrizione      
	  FROM PazientiUiBaseResult AS P
	  WHERE Id = @Id
 END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiAnonimizzazioniPazienteSelect] TO [DataAccessUi]
    AS [dbo];

