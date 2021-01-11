


CREATE PROCEDURE [dbo].[ProvenienzeUiUtentiLista]
	@Provenienza varchar(16)

AS
BEGIN
	SET NOCOUNT ON;

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT
		Id,
		dbo.GetNomeServizioById(1) AS Servizio,
		Utenti.Utente AS Utente,
		Utenti.Descrizione AS DescrizioneUtente,
		Provenienza,
		Lettura,
		Scrittura, 
		Cancellazione, 
		LivelloAttendibilita, 
		IngressoAck, 
		IngressoAckUrl, 
		NotificheAck, 
		NotificheUrl,
		CASE 
			WHEN (PazientiUtenti.Disattivato = 0) THEN 'Attivo'
			WHEN (PazientiUtenti.Disattivato = 1) THEN 'Disattivato'
			ELSE '' 
		END AS Disattivato

	FROM PazientiUtenti
		INNER JOIN Utenti ON PazientiUtenti.Utente = Utenti.Utente

	WHERE Provenienza = @Provenienza

UNION

	SELECT 
		Id,
		dbo.GetNomeServizioById(2) AS Servizio,
		Utenti.Utente AS Utente,
		Utenti.Descrizione AS DescrizioneUtente,
		Provenienza, 
		Lettura, 
		Scrittura,
		Cancellazione,
		LivelloAttendibilita, 
		IngressoAck, 
		IngressoAckUrl, 
		NotificheAck, 
		NotificheUrl, 
		CASE 
			WHEN (ConsensiUtenti.Disattivato = 0) THEN 'Attivo'
			WHEN (ConsensiUtenti.Disattivato = 1) THEN 'Disattivato'
			ELSE '' 
		END AS Disattivato

	FROM ConsensiUtenti
		INNER JOIN Utenti ON ConsensiUtenti.Utente = Utenti.Utente

	WHERE Provenienza = @Provenienza

ORDER BY Servizio, DescrizioneUtente

END

















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ProvenienzeUiUtentiLista] TO [DataAccessUi]
    AS [dbo];

