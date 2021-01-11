

CREATE PROCEDURE [frontend].[PazientiPatientSummaryAggiorna]
(
	@IdPaziente UNIQUEIDENTIFIER
	, @Pdf IMAGE
	, @Errore VARCHAR(4096)
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsPazientiPatientSummaryAggiorna
		Aggiorna/inserisce i dati del patient summary per il paziente con Id = @IdPaziente

	MODIFICA SANDRO 2016-06-28:
		Campo PDF modifiato in VARBINARY(MAX)

*/
	SET NOCOUNT ON;
	
	IF DATALENGTH(@Pdf) = 0 
		SET @Pdf = NULL

	IF EXISTS(SELECT * FROM PazientiAnteprima WHERE IdPaziente = @IdPaziente)
	BEGIN 
		UPDATE PazientiAnteprima 
			SET PatientSummaryDataModifica = GETDATE()
				, PatientSummaryErrore = @Errore
				, PatientSummaryPdf = CONVERT(VARBINARY(MAX), @Pdf)
				, PatientSummaryCda = NULL
		WHERE IdPaziente = @IdPaziente
	END 
	ELSE
	BEGIN 
		INSERT INTO PazientiAnteprima (IdPaziente, DataInserimento, PatientSummaryPdf, PatientSummaryDataModifica, PatientSummaryErrore)
		VALUES (@IdPaziente, GETDATE(), CONVERT(VARBINARY(MAX), @Pdf), GETDATE(), @Errore)
	END
	
	SELECT 
		IdPaziente
		, PatientSummaryDataModifica
		, PatientSummaryErrore 
	FROM 
		PazientiAnteprima 
	WHERE 
		IdPaziente = @IdPaziente
	
END



