
-- =============================================
-- Author:		SimoneB
-- Create date: 2017-12-07
-- Description:	Scrive un nuovo record dentro NotificheEmail. Usata dal frontend per inviare il link all'accesso diretto.
-- =============================================
CREATE PROCEDURE [frontend].[NotificheEmailInserisce]
(
	@Mittente          varchar(128),
	@Destinatario           varchar(512),
	@CopiaConoscenza           varchar(512),
	@CopiaConoscenzaNascosta           varchar(512),
	@Oggetto		varchar(1024),
	@Messaggio      text
)
AS

	SET NOCOUNT ON
	--
	-- Inserisco la nuova email
	--
	INSERT INTO NotificheEmail
		(
		Mittente,
		Destinatario,
		CopiaConoscenza,
		CopiaConoscenzaNascosta,
		Oggetto,
		Messaggio,
		Inviata,
		DataInserimento,
		DataInvio
		)
	VALUES
		(
		@Mittente,
		@Destinatario,
		@CopiaConoscenza,
		@CopiaConoscenzaNascosta,
		@Oggetto,
		@Messaggio,
		0,
		GetDate(),
		NULL
		)