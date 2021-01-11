


CREATE VIEW [dbo].[PazientiDatiRoot]
AS
/*
	CRAETA DA ETTORE 2105-10-27: Restituisce i dati paziente della root della fusione (il padre dell'intera catena di fusione)
*/
SELECT 
	Pazienti.Id AS FusioneId, 
	Pazienti.Provenienza AS FusioneProvenienza, 
	Pazienti.IdProvenienza AS FusioneIdProvenienza,
	PazientiFusioni.IdPazienteFuso

FROM PazientiFusioni 
	INNER JOIN Pazienti ON PazientiFusioni.IdPaziente = Pazienti.Id

WHERE PazientiFusioni.Abilitato = 1
GO
GRANT SELECT
    ON OBJECT::[dbo].[PazientiDatiRoot] TO [DataAccessSql]
    AS [dbo];

