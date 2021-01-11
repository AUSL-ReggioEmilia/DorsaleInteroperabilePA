
-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2018-02-22
-- Description:	Utilizzata per la visualizzazione di dettaglio del paziente per il quale si deve creare la "posizione collegata"
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiPosizioniCollegatePazienteSelect]
(
	@Id UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	Utilizzata per la visualizzazione di dettaglio del paziente per il quale si deve creare la "posizione collegata"
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
    ON OBJECT::[dbo].[PazientiUiPosizioniCollegatePazienteSelect] TO [DataAccessUi]
    AS [dbo];

