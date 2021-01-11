
CREATE FUNCTION [dbo].[GetPatientSummaryIsValid]
(
 @PatientSummaryDataModifica DATETIME
 , @PatientSummaryErrore VARCHAR(2048)
 , @Now DATETIME
)  
RETURNS BIT 
AS  
BEGIN
	DECLARE @IsValid AS BIT = 0
	
	DECLARE @DataMaxValidita DATETIME 
	IF (NOT @PatientSummaryDataModifica IS NULL) AND (@PatientSummaryErrore  IS NULL)
	BEGIN 
		--
		-- Il patient summary è presente su database e non ci sono errori
		--
		-- Verifico la validità temporale
		--
		SET @DataMaxValidita = CONVERT(DATETIME, CONVERT(VARCHAR(10), @PatientSummaryDataModifica, 120 ), 120)
		SET @DataMaxValidita = DATEADD(HOUR, 23, @DataMaxValidita)
		SET @DataMaxValidita = DATEADD(MINUTE, 59, @DataMaxValidita)
		SET @DataMaxValidita = DATEADD(SECOND, 59, @DataMaxValidita)
		IF @DataMaxValidita > @Now
			SET @IsValid = 1			
	END
	
	RETURN @IsValid

END


