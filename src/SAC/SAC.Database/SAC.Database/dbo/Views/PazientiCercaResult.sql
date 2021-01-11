


CREATE VIEW [dbo].[PazientiCercaResult]
AS
/*
	MODIFICA ETTORE 2014-07-02: Restituzione della DataDecesso
*/
SELECT 
	  Id
	, Provenienza
	, IdProvenienza
	, LivelloAttendibilita
	, DataInserimento
	, DataModifica

	, Tessera
	, Cognome
	, Nome
	, DataNascita
	, Sesso
	, ComuneNascitaCodice
	, dbo.LookupIstatComuni(ComuneNascitaCodice) AS ComuneNascitaNome
	, NazionalitaCodice
	, dbo.LookupIstatNazioni(NazionalitaCodice) AS NazionalitaNome
	, CodiceFiscale	
	, CodiceFiscaleMedicoDiBase
	-- Restituzione di DataDecesso
	, [dbo].[GetPazientiDataDecesso](Id) As DataDecesso
FROM
	Pazienti with(nolock)

WHERE
		Disattivato = 0
	AND Occultato = 0

