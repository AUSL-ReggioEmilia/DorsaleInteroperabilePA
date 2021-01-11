CREATE PROCEDURE [dbo].[SrvcStampeSottoscrizioniAggiorna]
(
	@Id uniqueidentifier,	--Id della sottoscrisione
	@Stato INT
)
AS
BEGIN
/*
	Stato:
		Attiva = 1
        RichiestaDisattivazione = 2
        Disattivata = 3
*/
	SET NOCOUNT ON;
	UPDATE StampeSottoscrizioni
		SET Stato= @Stato
			,DataModifica = GETDATE()
	WHERE Id = @Id

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeSottoscrizioniAggiorna] TO [ExecuteService]
    AS [dbo];

