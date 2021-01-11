

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE VIEW [dbo].[CUSTOM_AdminPrestazioniAttributi]
AS
SELECT  P.IdRefertiBase
		, P.PrestazioneCodice
		, P.PrestazioneDescrizione

		, PA.Nome AS AttributoNome
		, PA.Valore AS AttributoValore
FROM         store.Prestazioni AS P WITH(NOLOCK) INNER JOIN
                      store.PrestazioniAttributi AS PA WITH(NOLOCK) 
	 ON P.Id = PA.IdPrestazioniBase;

GO
GRANT SELECT
    ON OBJECT::[dbo].[CUSTOM_AdminPrestazioniAttributi] TO [ExecuteFrontEnd]
    AS [dbo];

