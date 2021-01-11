
-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Restituisce gli id dei referti (ancora esistenti) associati a note ancora da notificare 
-- Modify date: 2018-06-07 - ETTORE: Utilizzo della vista store.RefertiBase
-- =============================================
CREATE PROCEDURE [dbo].[BeRefertiNoteRefertiDaNotificareLista]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT 
		RN.IdRefertiBase --Guid del Dwh
	FROM 
		RefertiNote AS RN
	WHERE
		(RN.Notificata = 0)
		AND
		(RN.Cancellata = 0) --aggiunto il 07/05/2009
		--solo se il referto è presente		
        AND EXISTS(select * from store.RefertiBase AS RB where RN.IdRefertiBase = RB.Id) 
	SET NOCOUNT OFF;
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRefertiNoteRefertiDaNotificareLista] TO [ExecuteService]
    AS [dbo];

