




CREATE VIEW [dbo].[_DA_CANCELLARE_PazientiFusiMapping]
AS
/*
	Ritorna il mapping IdPazienteFuso --> IdPaziente (padre e attivo)
*/

SELECT DISTINCT
	  ISNULL(PazientiFusioni.IdPaziente, Pazienti.ID) AS IdPaziente
	, Pazienti.Id AS IdPazienteFuso

FROM Pazienti with(nolock) LEFT JOIN PazientiFusioni with(nolock)
	ON Pazienti.ID = PazientiFusioni.IdPAzienteFuso

WHERE
	PazientiFusioni.Abilitato = 1

