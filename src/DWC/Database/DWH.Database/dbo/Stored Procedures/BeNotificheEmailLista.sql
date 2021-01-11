

-- =============================================
-- Author:		Ettore
-- Create date: 
-- Description:	Restituisce l'elenco delle email da inviare
-- Modify date: 2018-01-15 - ETTORE - Eliminato i caratteri CHAR(10) e CHAR(13) dal campo Oggetto
--										Potrebbero essere presenti quando si cea email a partire dalle note del referto
-- Modify date: 2019-03-18 - ETTORE - Modificato filtro where affinchè dopo N tentativi se la mail non è stata inviata il record non venga restituito
-- =============================================
CREATE PROCEDURE [dbo].[BeNotificheEmailLista]
AS
BEGIN
	--
	-- Restituisce l'elenco delle email non ancora inviate
	--
	SET NOCOUNT ON

	DECLARE @DateNow datetime
	DECLARE @MaxNumeroTentativi INT

	SET @DateNow = GetDate()
	--
	-- Imposto il numero massimo di tentativi di invio di una notifica
	--
	SET @MaxNumeroTentativi = 10
	--
	-- Pongo a fallite tutte le notifiche email che sono state inserite N giorni fa o più)
	-- e che ad oggi non sono state inviate (-> DATEDIFF(day, DataInserimento, @DateNow) >= N ) 
	-- Fallimento equivale NumeroTentativi = @MaxNumeroTentativi
	--
	UPDATE NotificheEmail
		SET NumeroTentativi = @MaxNumeroTentativi
	FROM 
		NotificheEmail
		INNER JOIN (SELECT Id FROM NotificheEmail WHERE DATEDIFF(day, DataInserimento, @DateNow) >= 3) AS NotificheEmail_2 
		ON NotificheEmail.Id = NotificheEmail_2.Id
	WHERE
		NumeroTentativi < @MaxNumeroTentativi

	--
	-- Incremento di uno il contatore delle email da inviare e che non sono failed
	--
	UPDATE NotificheEmail
		SET NumeroTentativi = ISNULL(NumeroTentativi,0) + 1
	WHERE
		(Inviata = 0)
		AND 
		(ISNULL(NumeroTentativi,0) < @MaxNumeroTentativi ) 

	SELECT     
		Id, 
		Mittente, 
		Destinatario, 
		CopiaConoscenza, 
		CopiaConoscenzaNascosta, 
		REPLACE(Oggetto, CHAR(13)+CHAR(10), ' ') AS Oggetto, 
		Messaggio, 
		Inviata
	FROM         
		NotificheEmail
	WHERE
		(Inviata = 0) 
		AND (ISNULL(NumeroTentativi,0)< @MaxNumeroTentativi)

	SET NOCOUNT OFF
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeNotificheEmailLista] TO [ExecuteService]
    AS [dbo];

