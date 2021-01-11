


-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE PROCEDURE [dbo].[_Schedule_AttivitaGiornaliere] 
AS
BEGIN
/*
Occurs every day every 1 hour(s) between 07:23:00 and 18:23:59.
 Schedule will be used starting on 12/9/2008.
*/
DECLARE @DataIeri datetime

	SET @DataIeri = DATEADD(day, -1, GETDATE())

	--EXEC dbo.MntRefertiAssociaPaziente @DataIeri
	--EXEC dbo.MntEventiRicoveroAssociaPaziente @DataIeri
	
	-- Referti di EIM se in corso diventano Annullati

	UPDATE [store].[RefertiBase]
	SET StatoRichiestaCodice=3
	  WHERE [IdEsterno] LIKE 'AUSL_EIM%'
		AND StatoRichiestaCodice=0
		AND DataModifica > @DataIeri

	UPDATE [store].[RefertiBase]
	SET StatoRichiestaCodice=3
	  WHERE [IdEsterno] LIKE 'ASMN_EIM%'
		AND StatoRichiestaCodice=0
		AND DataModifica > @DataIeri

END
