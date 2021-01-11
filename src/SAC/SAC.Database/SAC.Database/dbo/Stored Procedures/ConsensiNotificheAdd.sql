

CREATE PROCEDURE [dbo].[ConsensiNotificheAdd] 
	  @IdConsenso AS uniqueidentifier
	, @Tipo AS tinyint
	, @Utente AS varchar(64)
AS
BEGIN

DECLARE @IdNotifica AS uniqueidentifier

	SET NOCOUNT ON;

	SET @IdNotifica = NEWID()
	--
	-- Notifica
	--
	INSERT INTO ConsensiNotifiche
						  (Id, IdConsenso, Tipo, Utente)
	VALUES     (@IdNotifica, @IdConsenso, @Tipo, @Utente)
	--
	-- Utente anonimo
	--
	INSERT INTO ConsensiNotificheUtenti (IdConsensiNotifica)
	VALUES     (@IdNotifica)
	--
	-- Utente con ACK
	--
	INSERT INTO ConsensiNotificheUtenti
						  (IdConsensiNotifica, InvioUtente, InvioSoapUrl)
	SELECT     @IdNotifica AS IdConsensiNotifica, Utente, NotificheUrl
	FROM         ConsensiUtenti
	WHERE     (NotificheAck = 1)

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiNotificheAdd] TO [DataAccessUi]
    AS [dbo];

