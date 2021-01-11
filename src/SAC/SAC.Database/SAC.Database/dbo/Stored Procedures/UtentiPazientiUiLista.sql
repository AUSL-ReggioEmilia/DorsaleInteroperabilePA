


CREATE PROCEDURE [dbo].[UtentiPazientiUiLista]
AS
BEGIN
	SET NOCOUNT ON;
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	SELECT     
		PazientiUtenti.Id, 
		PazientiUtenti.Utente, 
		PazientiUtenti.Provenienza, 
		PazientiUtenti.LivelloAttendibilita, 
		Utenti.Descrizione AS UtenteDescrizione, 
		Provenienze.Descrizione AS ProvenienzaDescrizione,
		PazientiUtenti.Disattivato
	FROM         
		PazientiUtenti INNER JOIN Utenti 
			ON PazientiUtenti.Utente = Utenti.Utente 
		INNER JOIN Provenienze 
			ON PazientiUtenti.Provenienza = Provenienze.Provenienza
	ORDER BY 
		PazientiUtenti.Utente

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiPazientiUiLista] TO [DataAccessUi]
    AS [dbo];

