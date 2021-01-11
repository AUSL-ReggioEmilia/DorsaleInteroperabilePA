

-- =============================================
-- Author:		Ettore
-- Create date: 2016-06-23
-- Modify date  2016-06-28 SANDRO - Campo PDF modifiato in VARBINARY(MAX) e aumentato campo Errore
-- Description:	Restituisce i campi del PatientSummary e la sua validità
-- =============================================
CREATE PROCEDURE [ws3].[PazientePatientSummaryOttieniById]
(
	@IdPaziente UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	Restituisce i campi del "Patient Summary" del paziente e il suo stato di validità
	Se è presente un errore 
*/
	SET NOCOUNT ON;

	SELECT 
		PatientSummaryPdf AS Pdf
		, PatientSummaryCda AS Cda
		, PatientSummaryErrore AS Errore
		, dbo.GetPatientSummaryIsValid(PatientSummaryDataModifica, NULL, GETDATE()) AS Valido
	FROM 
		PazientiAnteprima 
	WHERE 
		IdPaziente = @IdPaziente
END