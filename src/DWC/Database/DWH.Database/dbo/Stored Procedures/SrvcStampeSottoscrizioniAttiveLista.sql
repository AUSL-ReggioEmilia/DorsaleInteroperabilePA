

CREATE PROCEDURE [dbo].[SrvcStampeSottoscrizioniAttiveLista]
AS
BEGIN
/*
	Modifica Ettore 2013-04-22: aggiunto filtro su DataInizio
	Modifica Ettore 2017-01-09: aggiunto campo NumeroCopie

	Note:
	StatoRichiesta:
		Attiva = 1
        RichiestaDisattivazione = 2
        Disattivata = 3
        Timeout = 4
*/

	SET NOCOUNT ON;
	--
	-- Restituisce le richieste di stampa attive
	--
	SELECT Id
      , DataInserimento
      , Account
      , DataInizio
      , DataFine
      , ServerDiStampa
      , Stampante
      , Stato
	  , TipoReferti --0=tutti, 1=Definitivi
	  , NumeroCopie
	FROM 
		StampeSottoscrizioni
	WHERE 
		(Stato IN(1,2)) --Attiva, RichiestaDisattivazione
		AND GETDATE() > DataInizio
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeSottoscrizioniAttiveLista] TO [ExecuteService]
    AS [dbo];

