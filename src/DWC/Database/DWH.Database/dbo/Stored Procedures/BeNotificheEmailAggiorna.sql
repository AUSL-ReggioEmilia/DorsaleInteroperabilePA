
CREATE PROCEDURE [dbo].[BeNotificheEmailAggiorna]
(
@Id int,
@Inviata bit=0
)
AS
--#####################################
-- Copyright AUSL di Reggio Emilia
-- SPDX-License-Identifier: EUPL-1.2 
--#####################################

	SET NOCOUNT ON

	UPDATE NotificheEmail
		SET Inviata=@Inviata,
		DataInvio=GETDATE()
	WHERE 
		Id=@Id

	IF @@ERROR=0
		select 'ReturnValue'=0
	ELSE
		select 'ReturnValue'=1

	SET NOCOUNT OFF

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeNotificheEmailAggiorna] TO [ExecuteService]
    AS [dbo];

