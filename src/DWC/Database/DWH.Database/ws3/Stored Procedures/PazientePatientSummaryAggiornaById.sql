

-- =============================================
-- Author:		Ettore
-- Create date: 2016-06-23
-- Modify date  2016-06-28 SANDRO - Campo PDF modifiato in VARBINARY(MAX) e aumentato campo Errore
-- Description:	Aggiorna i campi del "Patient Summary" nella tabella PazientiAnteprima
-- =============================================
CREATE PROCEDURE [ws3].[PazientePatientSummaryAggiornaById]
(
	@IdPaziente UNIQUEIDENTIFIER
	, @Pdf VARBINARY(MAX)
	, @Cda VARBINARY(MAX)
	, @Errore VARCHAR(4096)
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsPazientiPatientSummaryAggiorna
		Aggiorna/inserisce i dati del patient summary per il paziente con Id = @IdPaziente
*/
	SET NOCOUNT ON;
	
	IF DATALENGTH(@Pdf) = 0 
		SET @Pdf = NULL

	IF DATALENGTH(@Cda) = 0 
		SET @Cda = NULL

	IF EXISTS(SELECT * FROM PazientiAnteprima WHERE IdPaziente = @IdPaziente)
	BEGIN 
		UPDATE PazientiAnteprima 
			SET PatientSummaryDataModifica = GETDATE()
				, PatientSummaryErrore = @Errore
				, PatientSummaryPdf = @Pdf
				, PatientSummaryCda = @Cda
		WHERE IdPaziente = @IdPaziente
	END 
	ELSE
	BEGIN 
		INSERT INTO PazientiAnteprima (IdPaziente, DataInserimento, PatientSummaryPdf, PatientSummaryCda, PatientSummaryDataModifica, PatientSummaryErrore)
		VALUES (@IdPaziente, GETDATE(), @Pdf, @Cda, GETDATE(), @Errore)
	END
	
END