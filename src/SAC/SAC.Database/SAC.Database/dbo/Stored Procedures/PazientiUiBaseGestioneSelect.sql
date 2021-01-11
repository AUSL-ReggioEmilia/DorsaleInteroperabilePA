


CREATE PROCEDURE [dbo].[PazientiUiBaseGestioneSelect]
(
	@Id AS uniqueidentifier
)
AS
BEGIN
/*
	MODIFICA ETTORE 2014-03-26
		1) Tolto * e aggiunto tutti i campi della vista PazientiUiBaseGestioneResult

*/
	SET NOCOUNT ON;

	SELECT 
		PGR.Id
		, PGR.DataModifica
		, PGR.DataDisattivazione
		, PGR.LivelloAttendibilita
		, PGR.Disattivato
		, PGR.DisattivatoDescrizione
		, PGR.Provenienza
		, PGR.IdProvenienza
		, PGR.Occultato
		, PGR.Cognome
		, PGR.Nome
		, PGR.DataNascita
		, PGR.ComuneNascitaNome
		, PGR.ProvinciaNascitaNome
		, PGR.Sesso
		, PGR.CodiceFiscale
		, PGR.Tessera
		, PGR.ComuneResDescrizione
		, PGR.ProvinciaResDescrizione
		, PGR.RegioneResDescrizione

	FROM 
		PazientiUiBaseGestioneResult AS PGR
	WHERE PGR.Id = @Id

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiBaseGestioneSelect] TO [DataAccessUi]
    AS [dbo];

