CREATE PROCEDURE [dbo].[BeRefertiNoteDaNotificareAggiorna]
(
@Id as uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE RefertiNote
		SET Notificata = 1 
	WHERE
		Id = @Id

	SET NOCOUNT OFF;
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRefertiNoteDaNotificareAggiorna] TO [ExecuteService]
    AS [dbo];

