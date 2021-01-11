

CREATE PROCEDURE [frontend].[PazientiPatientSummaryOttieni]
(
	@IdPaziente UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsPazientiPatientSummaryOttieni

	MODIFICA SANDRO 2016-06-28:
		Campo PDF modifiato in VARBINARY(MAX)
		
	Restituisce il PDF del patient summary del paziente solo se è valido
*/
	SET NOCOUNT ON;
	SELECT 
		PatientSummaryDataModifica
		, PatientSummaryErrore
		, CONVERT(IMAGE, PatientSummaryPdf) PatientSummaryPdf 
	FROM 
		PazientiAnteprima 
	WHERE 
		IdPaziente = @IdPaziente
		AND (NOT PatientSummaryPdf IS NULL) --è presente il PDF
		AND (PatientSummaryErrore IS NULL)  --non ci sono errori
		AND dbo.GetPatientSummaryIsValid(PatientSummaryDataModifica, PatientSummaryErrore, GETDATE()) =  1
END


