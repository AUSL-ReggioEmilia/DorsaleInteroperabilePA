
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-20 - Rimosso raggruppamento referti modificati
-- Modify date: 2016-09-16 - Controlla se esiste ancora
-- Modify date: 2016-11-11 - Ritorna anche lo stato degli oscuramenti
-- Modify date: 2017-09-12 - Ordina per DataInvio
-- Modify date: 2017-11-06 - Se è una cancellazione, non controlla se esiste 
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Modify date: 2019-01-22 Refactoring cambio schema
--
-- Description:	Ritorna la lista dei referti inviati dopo la DATA specificata
--					Solo completati ed inviati da 30 secondi
--					USATO dal connettore SOLE
-- =============================================
CREATE FUNCTION [sole_da].[OttieniRefertiOutputInviati]
(	
 @DataLast DATETIME
,@MaxRecord INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP(@MaxRecord)
			 cr.DataInvio
			,cr.IdReferto
			,cr.Operazione
			,cr.Messaggio.value('(/*/StatoRichiestaCodice)[1]', 'varchar(1)') AS StatoRichiestaCodice
			,cr.Messaggio.value('(/*/AziendaErogante)[1]', 'varchar(64)') AS AziendaErogante
			,cr.Messaggio.value('(/*/SistemaErogante)[1]', 'varchar(64)') AS SistemaErogante
			,CONVERT(XML,dbo.decompress(cr.MessaggioCompresso)) AS RefertoXml

			-- Oscuramenti
			,ISNULL(o.Confidenziale, 0) AS Confidenziale
			,o.Oscurato
		
	FROM [dbo].[CodaRefertiOutputInviati] AS cr WITH(NOLOCK)
		OUTER APPLY [sole].[OttieniOscuramentiPerReferto](cr.IdReferto) o
	
	WHERE cr.DataInvio > @DataLast
		AND cr.DataInvio < DATEADD(second, -30, GETUTCDATE())

		-- 2017-11-06  oppure è una cancellazione
		AND (cr.Messaggio.value('(/*/StatoRichiestaCodice)[1]', 'varchar(1)') <> '0'
				OR cr.Operazione = 2
			)

		-- Esiste ancora
		-- 2017-11-06  oppure è una cancellazione
		AND ( EXISTS (SELECT * FROM [store].[RefertiBase] WHERE ID = cr.IdReferto)
				OR cr.Operazione = 2
			)

	ORDER BY cr.DataInvio
)