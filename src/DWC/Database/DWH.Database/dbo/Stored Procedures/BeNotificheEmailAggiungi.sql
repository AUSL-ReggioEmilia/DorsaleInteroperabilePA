﻿CREATE PROCEDURE [dbo].[BeNotificheEmailAggiungi]
(
@Mittente          varchar(128),
)
AS

	SET NOCOUNT ON
	--
	-- Inserisco la nuova email
	--
	INSERT INTO NotificheEmail
		(
		Mittente,
		Inviata,
	VALUES
		(
		@Mittente,
		0,

	SET NOCOUNT OFF

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeNotificheEmailAggiungi] TO [ExecuteService]
    AS [dbo];
