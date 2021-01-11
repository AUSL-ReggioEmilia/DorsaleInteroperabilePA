



CREATE PROCEDURE [frontend].[PazientiPatientSummaryStato]
(
	@IdPaziente UNIQUEIDENTIFIER
)
AS
BEGIN
/*

	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsPazientiPatientSummaryStato

	MODIFICA SANDRO 2016-06-28:
		Campo PDF modifiato in VARBINARY(MAX) e aumentato il campo Errore

	Restituisce 1 se il patient summary è valido, altrimenti 0 e la dimensione del PDF
	In alcuni casi la dimensione del PDF è 0 se il paziente NON ESISTE o NON HA IL PATIENT SUMMARY
*/
	SET NOCOUNT ON;
	DECLARE @IsValid BIT = 0
	DECLARE @PatientSummaryDataModifica DATETIME = NULL
	DECLARE @PatientSummaryErrore VARCHAR(4096) = NULL
	DECLARE @DataMaxValidita DATETIME 
	DECLARE @PatientSummaryPdfLength INTEGER

	SELECT 
		@PatientSummaryDataModifica = PatientSummaryDataModifica 
		, @PatientSummaryErrore = PatientSummaryErrore 
		, @PatientSummaryPdfLength = ISNULL(DATALENGTH(PatientSummaryPdf), 0)
	FROM PazientiAnteprima 
	WHERE IdPaziente = @IdPaziente
	
	--
	-- Verifico la validità
	--	
	SELECT @IsValid = dbo.GetPatientSummaryIsValid(@PatientSummaryDataModifica, @PatientSummaryErrore, GETDATE())

	--
	-- Restituisco
	-- Se per il paziente non c'è patient summary il PDF è NULL e non devo mostrare pulsante per aprire il patient summary
	-- a prescindere dal fatto che abbia già fatto la query: se per un paziente non viene restituito il patient summary in questo modo si aspetta fino 
	-- alla fine della validità dell'ultima chiamata al web service
	--
	SELECT 
		@IsValid AS IsValid
		, @PatientSummaryPdfLength AS PdfLength
		
END


