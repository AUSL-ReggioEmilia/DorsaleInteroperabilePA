


CREATE PROCEDURE [dbo].[UtentiUiServiziLista]
	@Utente varchar(64)

AS
BEGIN
	SET NOCOUNT ON;
			
	SELECT
		PU.Id,
		S.NOME AS Servizio,
		Provenienza,
		Lettura,
		Scrittura, 
		Cancellazione, 
		LivelloAttendibilita, 
		IngressoAck, 
		IngressoAckUrl, 
		NotificheAck, 
		NotificheUrl,
		CASE Disattivato
			WHEN 0 THEN 'Attivo'
			WHEN 1 THEN 'Disattivato'
			ELSE '' 
		END AS Disattivato,
		'UtentePazienteDettaglio.aspx' AS DetailPage

	FROM dbo.Servizi S
	LEFT JOIN PazientiUtenti AS PU ON PU.Utente = @Utente
	WHERE S.ID = 1

  UNION ALL

	SELECT 
		CU.Id,
		S.NOME AS Servizio,
		Provenienza, 
		Lettura, 
		Scrittura,
		Cancellazione,
		LivelloAttendibilita, 
		IngressoAck, 
		IngressoAckUrl, 
		NotificheAck, 
		NotificheUrl, 
		CASE Disattivato
			WHEN 0 THEN 'Attivo'
			WHEN 1 THEN 'Disattivato'
			ELSE '' 
		END AS Disattivato,
		'UtenteConsensoDettaglio.aspx' AS DetailPage
	
	FROM dbo.Servizi S
	LEFT JOIN ConsensiUtenti AS CU ON CU.Utente = @Utente
	WHERE S.ID = 2
 
  UNION ALL

	SELECT 
		PU.Id AS Id,
		S.NOME AS Servizio,
		CAST(NULL AS VARCHAR) AS Provenienza, 
		CAST(Lettura AS BIT)  AS Lettura,
		CAST(Scrittura AS BIT)  AS Scrittura,
		CAST(Cancellazione AS BIT)  AS Cancellazione,
		CAST(NULL AS TINYINT) AS LivelloAttendibilita, 
		CAST(NULL AS BIT) AS IngressoAck, 
		CAST(NULL AS VARCHAR) AS IngressoAckUrl, 
		CAST(NULL AS BIT) AS NotificheAck, 
		CAST(NULL AS VARCHAR) AS NotificheUrl, 
		CASE Disattivato
			WHEN 0 THEN 'Attivo'
			WHEN 1 THEN 'Disattivato'
			ELSE '' 
		END AS Disattivato,
		'PermessiUtenteDettaglio.aspx' AS DetailPage

	FROM  dbo.Servizi S
	LEFT JOIN organigramma.PermessiUtenti AS PU ON PU.Utente = @Utente
	WHERE S.ID = 8

	UNION ALL

	SELECT 
		EU.Id AS Id,
		S.NOME AS Servizio,
		Provenienza, 
		CAST(EU.Lettura AS BIT)  AS Lettura,
		CAST(EU.Scrittura AS BIT)  AS Scrittura,
		CAST(EU.Cancellazione AS BIT)  AS Cancellazione,
		CAST(EU.LivelloAttendibilita AS TINYINT) AS LivelloAttendibilita, 
		CAST(NULL AS BIT) AS IngressoAck, 
		CAST(NULL AS VARCHAR) AS IngressoAckUrl, 
		CAST(NULL AS BIT) AS NotificheAck, 
		CAST(NULL AS VARCHAR) AS NotificheUrl, 
		CASE EU.Disattivato
			WHEN 0 THEN 'Attivo'
			WHEN 1 THEN 'Disattivato'
			ELSE '' 
		END AS Disattivato,
		'UtenteEsenzioneDettaglio.aspx' AS DetailPage

	FROM  dbo.Servizi S
	LEFT JOIN dbo.EsenzioniUtenti AS EU ON EU.Utente = @Utente
	WHERE S.ID = 9

  ORDER BY S.NOME

END









GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UtentiUiServiziLista] TO [DataAccessUi]
    AS [dbo];

