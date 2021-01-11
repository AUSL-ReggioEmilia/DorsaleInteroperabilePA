



CREATE PROCEDURE [dbo].[BevsStampeSottoscrizioniAggiungi2]
(
	@Id UNIQUEIDENTIFIER
	, @Account VARCHAR(128)
	, @DataFine AS DATETIME
	, @IdTipoReferti AS INTEGER
	, @ServerDiStampa AS VARCHAR(64) 
	, @Stampante AS VARCHAR(64) 
	, @Nome AS VARCHAR(128)	
	, @Descrizione AS VARCHAR(1024)
	, @StampaConfidenziali AS BIT
	, @StampaOscurati AS BIT
	, @NumeroCopie AS TINYINT = 1
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-07-03: aggiunti i nuovi campi StampaConfidenziali e StampaOscurati
	MODIFICATA DA ETTORE 2017-01-09: aggiunto nuovo campo NumeroCopie
*/
/*
	All'inserimento la sottoscrizione viene impostata come Disattiva (Stato=3) 
	e di tipo ADMIN (TipoSottoscrizione=1)
*/
	SET NOCOUNT ON;
	DECLARE @IdStato INT
	DECLARE @IdTipoSottoscrizione INT

	SET @IdStato = 3 --DISATTIVA
	SET @IdTipoSottoscrizione = 1 --ADMIN
	
	SET @ServerDiStampa = '\\' + REPLACE(@ServerDiStampa , '\', '')
		
	INSERT INTO StampeSottoscrizioni(Id, Account, DataInizio, DataFine, TipoReferti, ServerDiStampa, Stampante, Stato ,TipoSottoscrizione, Nome, Descrizione, StampaConfidenziali, StampaOscurati, NumeroCopie)
    VALUES (@Id, @Account, GETDATE(), @DataFine, @IdTipoReferti, @ServerDiStampa, @Stampante, @IdStato , @IdTipoSottoscrizione, @Nome, @Descrizione, @StampaConfidenziali, @StampaOscurati, @NumeroCopie)

END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsStampeSottoscrizioniAggiungi2] TO [ExecuteFrontEnd]
    AS [dbo];

