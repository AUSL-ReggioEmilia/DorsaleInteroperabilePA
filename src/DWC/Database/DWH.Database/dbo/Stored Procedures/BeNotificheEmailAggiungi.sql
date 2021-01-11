CREATE PROCEDURE [dbo].[BeNotificheEmailAggiungi]
(
@Mittente          varchar(128),@Destinatario           varchar(512),@CopiaConoscenza           varchar(512),@CopiaConoscenzaNascosta           varchar(512),@Oggetto		varchar(1024),@Messaggio      text
)
AS

	SET NOCOUNT ON
	--
	-- Inserisco la nuova email
	--
	INSERT INTO NotificheEmail
		(
		Mittente,		Destinatario,		CopiaConoscenza,		CopiaConoscenzaNascosta,		Oggetto,		Messaggio,
		Inviata,		DataInserimento,		DataInvio		)
	VALUES
		(
		@Mittente,		@Destinatario,		@CopiaConoscenza,		@CopiaConoscenzaNascosta,		@Oggetto,		@Messaggio,
		0,		GetDate(),		NULL		)

	SET NOCOUNT OFF

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeNotificheEmailAggiungi] TO [ExecuteService]
    AS [dbo];

