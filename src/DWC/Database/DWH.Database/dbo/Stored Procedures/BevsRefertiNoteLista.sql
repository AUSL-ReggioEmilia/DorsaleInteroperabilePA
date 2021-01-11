
-- =============================================
-- Author:	???
-- Create date: ???
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- Description: Restituisce la lista delle "note ai referti"
-- =============================================
CREATE PROCEDURE [dbo].[BevsRefertiNoteLista]
(
	@NumeroReferto varchar(16)=NULL,
	@NumeroNosologico varchar(64)=NULL,
	@DataDal as datetime=NULL,
	@DataAl as datetime=NULL,
	@VisualizzaNoteCancellate as bit=1
)
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		RB.NumeroReferto
		,RB.NumeroNosologico
		,RN.Utente
		,RN.Data as DataInserimento
		,CAST(RN.Nota as varchar(200)) AS Nota
		,RN.Id as IdRefertiNote
		,RN.IdRefertiBase as IdReferti
		,RN.Cancellata
	FROM 
		RefertiNote AS RN
		inner join store.RefertiBase AS RB
			on RN.IDRefertibase = RB.Id
	WHERE
		(RB.NumeroReferto = @NumeroReferto OR @NumeroReferto IS NULL)
		AND
		(RB.NumeroNosologico = @NumeroNosologico OR @NumeroNosologico IS NULL)
		AND
		(@DataDal <= RN.Data OR @DataDal IS NULL)
		AND
		(RN.Data < DATEADD(day,1,@DataAl) OR @DataAl IS NULL)  
		AND
		(RN.Cancellata = 0 OR  @VisualizzaNoteCancellate = 1)
	SET NOCOUNT OFF;
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertiNoteLista] TO [ExecuteFrontEnd]
    AS [dbo];

