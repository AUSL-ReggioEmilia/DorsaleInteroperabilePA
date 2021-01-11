CREATE PROCEDURE [dbo].[MntConsensiNotificaArchivia]

AS
BEGIN

	SET NOCOUNT ON

	DECLARE @DateArchive AS DATETIME
	SELECT @DateArchive = COALESCE(MAX(Data), '2000-01-01') FROM ConsensiNotifiche_Storico

	PRINT 'Archivia da'
	PRINT @DateArchive

	-- COPY

	BEGIN TRAN

	SET NOCOUNT OFF	

	PRINT 'Archivia ConsensiNotificheUtenti'

	INSERT ConsensiNotificheUtenti_Storico (Id, IdConsensiNotifica, InvioUtente
										, InvioData, InvioEffettuato, InvioSoapUrl)
	SELECT nu.[Id]
		  ,nu.[IdConsensiNotifica]
		  ,nu.[InvioUtente]
		  ,nu.[InvioData]
		  ,nu.[InvioEffettuato]
		  ,nu.[InvioSoapUrl]
	FROM dbo.ConsensiNotificheUtenti nu
	WHERE nu.[IdConsensiNotifica] IN (
							SELECT TOP 100000 n.Id
							FROM dbo.ConsensiNotifiche n
							WHERE Data > @DateArchive
								AND Data < DATEADD(DAY, -1, GETDATE())
							ORDER BY Data
										)
	IF @@ERROR > 0 
		GOTO ERR_EXIT

	PRINT 'Archivia ConsensiNotifiche'

	INSERT ConsensiNotifiche_Storico (Id, IdConsenso, Tipo, Data, Utente)
	SELECT TOP 100000 N.Id
					, N.IdConsenso
					, N.Tipo
					, N.Data
					, N.Utente
	FROM dbo.ConsensiNotifiche n
	WHERE Data > @DateArchive
			AND Data < DATEADD(DAY, -1, GETDATE())
	ORDER BY Data

	IF @@ERROR > 0 
		GOTO ERR_EXIT

	--- DELETE 

	SELECT @DateArchive = COALESCE(MAX(Data), '2000-01-01') FROM ConsensiNotifiche_Storico
	PRINT 'Cancella da'
	PRINT @DateArchive

	PRINT 'Cancella ConsensiNotificheUtenti'

	DELETE ConsensiNotificheUtenti
	FROM dbo.ConsensiNotifiche n INNER JOIN dbo.ConsensiNotificheUtenti nu
				ON	n.id = nu.IdConsensiNotifica
	WHERE Data <= @DateArchive

	IF @@ERROR > 0 
		GOTO ERR_EXIT

	PRINT 'Cancella ConsensiNotifiche'

	DELETE ConsensiNotifiche
	WHERE  Data <= @DateArchive

	IF @@ERROR > 0 
		GOTO ERR_EXIT

	COMMIT
	RETURN 0

ERR_EXIT:

	ROLLBACK
	RETURN 1

END

