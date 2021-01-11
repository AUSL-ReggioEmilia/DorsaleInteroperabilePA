
-- =============================================
-- Author:	???
-- Create date: ???
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- Description: Restituisce il dettaglio di una "nota al referto"
-- =============================================
CREATE PROCEDURE [dbo].[BevsRefertiNoteDettaglio]
(
	@IdRefertiNote uniqueidentifier
)
AS
SET NOCOUNT ON;
SELECT 
	RN.Id as Id
	,RN.IdRefertiBase as IdReferti
	,RN.Utente
	,RN.Data as DataInserimento
	,RN.Nota
	,RB.NumeroNosologico
	,Rb.NumeroReferto
FROM 
	RefertiNote AS RN
	inner join store.RefertiBase AS RB 
		on RN.IDRefertibase = RB.Id
WHERE
	RN.Id = @IdRefertiNote
SET NOCOUNT OFF;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertiNoteDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

