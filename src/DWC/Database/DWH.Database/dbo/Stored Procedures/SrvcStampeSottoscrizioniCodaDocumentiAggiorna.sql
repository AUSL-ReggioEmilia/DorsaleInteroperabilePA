CREATE PROCEDURE [dbo].[SrvcStampeSottoscrizioniCodaDocumentiAggiorna]
(
	@Id uniqueidentifier
	,@Stato INT
	,@Errore as VARCHAR(2048)
	,@Ts TIMESTAMP

)
AS
BEGIN

	UPDATE StampeSottoscrizioniDocumentiCoda
		SET DataModifica = GETDATE()
		  ,Stato = @Stato
		  ,Errore = @Errore
	WHERE
		(Id = @Id)
		AND (Ts = @Ts)

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeSottoscrizioniCodaDocumentiAggiorna] TO [ExecuteService]
    AS [dbo];

