
CREATE PROCEDURE [dbo].[MntPazientiNotificaArchivia]

AS
BEGIN
/*
	MODIFICA ETTORE 2015-06-26: aggiunto campo IdPazienteFuso alle tabelle PazientiNotifica e PazientiNotifica_Storico
*/

	SET NOCOUNT ON

	DECLARE @DateArchive AS DATETIME
	SELECT @DateArchive = COALESCE(MAX(Data), '2000-01-01') FROM PazientiNotifiche_Storico

	PRINT 'Archivia da'
	PRINT @DateArchive

	-- COPY

	BEGIN TRAN

	SET NOCOUNT OFF	

	PRINT 'Archivia PazientiNotificheUtenti'

	INSERT PazientiNotificheUtenti_Storico (Id, IdPazientiNotifica, InvioUtente
										, InvioData, InvioEffettuato, InvioSoapUrl)
	SELECT nu.[Id]
		  ,nu.[IdPazientiNotifica]
		  ,nu.[InvioUtente]
		  ,nu.[InvioData]
		  ,nu.[InvioEffettuato]
		  ,nu.[InvioSoapUrl]
	FROM dbo.PazientiNotificheUtenti nu
	WHERE nu.[IdPazientiNotifica] IN (
							SELECT TOP 100000 n.Id
							FROM dbo.PazientiNotifiche n
							WHERE Data > @DateArchive
								AND Data < DATEADD(DAY, -1, GETDATE())
							ORDER BY Data
										)
	IF @@ERROR > 0 
		GOTO ERR_EXIT

	PRINT 'Archivia PazientiNotifiche'

	INSERT PazientiNotifiche_Storico (Id, IdPaziente, Tipo, Data, Utente, IdPazienteFuso)
	SELECT TOP 100000 N.Id
					, N.IdPaziente
					, N.Tipo
					, N.Data
					, N.Utente
					, N.IdPazienteFuso
	FROM dbo.PazientiNotifiche n
	WHERE Data > @DateArchive
			AND Data < DATEADD(DAY, -1, GETDATE())
	ORDER BY Data

	IF @@ERROR > 0 
		GOTO ERR_EXIT

	--- DELETE 

	SELECT @DateArchive = COALESCE(MAX(Data), '2000-01-01') FROM PazientiNotifiche_Storico
	PRINT 'Cancella da'
	PRINT @DateArchive

	PRINT 'Cancella PazientiNotificheUtenti'

	DELETE PazientiNotificheUtenti
	FROM dbo.PazientiNotifiche n INNER JOIN dbo.PazientiNotificheUtenti nu
				ON	n.id = nu.IdPazientiNotifica
	WHERE Data <= @DateArchive

	IF @@ERROR > 0 
		GOTO ERR_EXIT

	PRINT 'Cancella PazientiNotifiche'

	DELETE PazientiNotifiche
	WHERE  Data <= @DateArchive

	IF @@ERROR > 0 
		GOTO ERR_EXIT

	COMMIT
	RETURN 0

ERR_EXIT:

	ROLLBACK
	RETURN 1

END


