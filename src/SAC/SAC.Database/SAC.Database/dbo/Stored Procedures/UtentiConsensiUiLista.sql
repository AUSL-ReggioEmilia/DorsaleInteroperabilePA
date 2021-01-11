


CREATE PROCEDURE [dbo].[UtentiConsensiUiLista]
AS
BEGIN
	SET NOCOUNT ON;
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	SELECT     
		ConsensiUtenti.Id, 
		ConsensiUtenti.Utente, 
		ConsensiUtenti.Provenienza, 
		ConsensiUtenti.LivelloAttendibilita, 
		Utenti.Descrizione AS UtenteDescrizione, 
		Provenienze.Descrizione AS ProvenienzaDescrizione,
		ConsensiUtenti.Disattivato
	FROM         
		ConsensiUtenti INNER JOIN Utenti 
			ON ConsensiUtenti.Utente = Utenti.Utente 
		INNER JOIN Provenienze 
			ON ConsensiUtenti.Provenienza = Provenienze.Provenienza
	ORDER BY 
		ConsensiUtenti.Utente

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiConsensiUiLista] TO [DataAccessUi]
    AS [dbo];

