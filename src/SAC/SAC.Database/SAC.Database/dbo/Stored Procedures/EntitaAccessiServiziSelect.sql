
-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Restituisce i servizi per Pazienti e Consensi 
-- Modify date: 2018-02-22 - ETTORE: aggiunto la gestione dei campi per le "Posizioni collegate"
-- =============================================
CREATE PROCEDURE [dbo].[EntitaAccessiServiziSelect]
(
   @IdEntitaAccesso AS uniqueidentifier
)
AS
BEGIN

	SET NOCOUNT ON;
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	SELECT     
		EntitaAccessiServizi.Id
	  , EntitaAccessiServizi.IdServizio
	  , EntitaAccessiServizi.IdEntitaAccesso
	  , Servizi.Descrizione AS DescrizioneServizio
	  , EntitaAccessi.Nome
	  , EntitaAccessi.Dominio
	  , EntitaAccessi.Tipo
	  , EntitaAccessiServizi.Creazione
	  , EntitaAccessiServizi.Lettura
	  , EntitaAccessiServizi.Scrittura
	  , EntitaAccessiServizi.Eliminazione
	  , EntitaAccessiServizi.ControlloCompleto
	  , EntitaAccessiServizi.CreazioneAnonimizzazione
	  , EntitaAccessiServizi.LetturaAnonimizzazione
	  , EntitaAccessiServizi.CreazionePosizioneCollegata
	  , EntitaAccessiServizi.LetturaPosizioneCollegata

	FROM         
		EntitaAccessi 
		INNER JOIN EntitaAccessiServizi ON EntitaAccessi.Id = EntitaAccessiServizi.IdEntitaAccesso 
		INNER JOIN Servizi ON EntitaAccessiServizi.IdServizio = Servizi.Id
	WHERE
		IdEntitaAccesso = @IdEntitaAccesso
		--MODIFICA ETTORE 2014-01-17: Questo filtro è solo temporaneo per non restituire
		--servizi che al momento non sono implementati
		AND (Servizi.Id IN (1,2))

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[EntitaAccessiServiziSelect] TO [DataAccessUi]
    AS [dbo];

