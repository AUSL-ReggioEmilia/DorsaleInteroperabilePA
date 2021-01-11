


CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniDettaglio2]
(
	@Id AS UNIQUEIDENTIFIER
) 
AS
BEGIN
/*
	CREATA DA ETTORE 2015-07-03: restituito i nuovi campi StampaConfidenziali e StampaOscurati
	MODIFICATA DA ETTORE 2017-01-09: restituito nuovo campo NumeroCopie
*/
	SET NOCOUNT ON;
	SELECT 
		StampeSottoscrizioni.Id
      , StampeSottoscrizioni.Account
      , StampeSottoscrizioni.DataFine
      , StampeSottoscrizioni.TipoReferti AS IdTipoReferti
      , REPLACE(StampeSottoscrizioni.ServerDiStampa, '\', '') AS ServerDiStampa
      , StampeSottoscrizioni.Stampante
      , StampeSottoscrizioni.Stato AS IdStato
	  , StampeSottoscrizioniStati.Descrizione AS Stato
      , TipoSottoscrizione AS IdTipoSottoscrizione
	  , StampeSottoscrizioni.Nome
	  , ISNULL(StampeSottoscrizioni.Descrizione, '') AS Descrizione
	  , StampeSottoscrizioni.Ts 
	  , StampeSottoscrizioni.StampaConfidenziali
	  , StampeSottoscrizioni.StampaOscurati
	  , StampeSottoscrizioni.NumeroCopie
	FROM 
		StampeSottoscrizioni
		INNER JOIN StampeSottoscrizioniStati 
			ON StampeSottoscrizioni.Stato = StampeSottoscrizioniStati.Id
	WHERE
		StampeSottoscrizioni.Id = @Id
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniDettaglio2] TO [ExecuteFrontEnd]
    AS [dbo];

