
CREATE PROC [dbo].[PazientiUIAnonimizzazioniSelectByIdSacAnonimo]

(
	@IdSacAnonimo uniqueidentifier
)
AS
BEGIN
/*
	MODIFICA ETTORE: 2016-02-10 restituiti anche i dati della posizione anonima
*/
	SET NOCOUNT OFF
	SELECT 
		PA.IdAnonimo
		, PA.IdSacAnonimo --questo è l'Id dell'anagrafica SAC associata al codice IdAnonimo
		, PA.IdSacOriginale --questo è l'id dell'anagrafica reale 
		, PA.DataInserimento
		, PA.Utente
		, PA.Note
		-- DATI DELLA POSIZIONE ANAGRAFICA ANONIMA
		, P.Nome As AnonimoNome
		, P.Cognome As AnonimoCognome
		, P.Sesso As AnonimoSesso
		, P.DataNascita As AnonimoDataNascita
		--, (SELECT TOP 1 ISNULL(Nome, '') FROM IstatComuni WHERE Codice = P.ComuneNascitaCodice ) AS AnonimoComuneNascitaDescrizione
		--Hanno chiesto che ci sia sempre '000000'
		, '000000' AS AnonimoComuneNascitaDescrizione
		, P.CodiceFiscale AS AnonimoCodiceFiscale
	FROM  
		PazientiAnonimizzazioni AS PA
		INNER JOIN PazientiUiBaseResult AS P
			ON P.Id = PA.IdSacAnonimo
	WHERE 
		IdSacAnonimo = @IdSacAnonimo
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUIAnonimizzazioniSelectByIdSacAnonimo] TO [DataAccessUi]
    AS [dbo];

