CREATE PROCEDURE [dbo].[SrvcStampeSottoscrizioniCodaDaProcessareAggiorna]
(
	@Id UNIQUEIDENTIFIER,
	@Ts TIMESTAMP,
	@DataSottomissione datetime,  
	@Errore VARCHAR(2048)=NULL
)
AS
BEGIN
/*
StatoStampa:
		DaSottomettere = 1
        Sottomessa = 2
        Terminata = 3
*/
	SET NOCOUNT ON;

	UPDATE StampeSottoscrizioniCoda
		SET 
           Errore = @Errore 
			,DataModifica = GETDATE()
			 ,DataSottomissione = @DataSottomissione 
	WHERE 
		(Id = @Id)
		AND (Ts = @Ts)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SrvcStampeSottoscrizioniCodaDaProcessareAggiorna] TO [ExecuteService]
    AS [dbo];

