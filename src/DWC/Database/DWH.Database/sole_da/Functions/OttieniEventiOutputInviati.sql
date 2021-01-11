

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-23 - Rimosso raggruppamento referti modificati
-- Modify date: 2016-06-22 - Corretto errore di TipoRicoveroCodice NULL
-- Modify date: 2016-09-16 - Controlla se esiste ancora
-- Modify date: 2016-09-30 - DSM accetta anche TipoRicoveroCodice=A
-- Modify date: 2016-11-11 - Ritorna anche lo stato degli oscuramenti
-- Modify date: 2017-09-12 - Ordina per DataInvio
-- Modify date: 2017-11-06 - Se è una cancellazione, non controlla se esiste 
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
--
-- Description:	Ritorna la lista degli eventi inviati dopo la DATA specificata
--				Solo completati ed inviati da 30 secondi
--				USATO dal connettore SOLE
-- =============================================
CREATE FUNCTION [sole_da].[OttieniEventiOutputInviati]
(	
 @DataLast DATETIME
,@MaxRecord INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP(@MaxRecord)
			 ce.DataInvio
			,ce.IdEvento
			,ce.Operazione
			,ce.Messaggio.value('(/*/TipoEventoCodice)[1]', 'varchar(16)') AS TipoEventoCodice
			,ce.Messaggio.value('(/*/TipoRicoveroCodice)[1]', 'varchar(16)') AS TipoRicoveroCodice
			,ce.Messaggio.value('(/*/AziendaErogante)[1]', 'varchar(64)') AS AziendaErogante
			,ce.Messaggio.value('(/*/SistemaErogante)[1]', 'varchar(64)') AS SistemaErogante

			,CONVERT(XML,dbo.decompress(ce.MessaggioCompresso)) AS EventoXml

			-- Oscuramenti
			,ISNULL(o.Confidenziale, 0) AS Confidenziale
			,o.Oscurato
		
	FROM [dbo].[CodaEventiOutputInviati] AS ce WITH(NOLOCK)
		OUTER APPLY [sole].[OttieniOscuramentiPerEvento](ce.IdEvento) o		
	
	WHERE ce.DataInvio > @DataLast
		AND ce.DataInvio < DATEADD(second, -30, GETUTCDATE())
		AND ce.Messaggio.value('(/*/TipoEventoCodice)[1]', 'varchar(16)') IN ('A', 'D', 'X', 'R', 'E')
		
		--2016-06-22 - Corretto errore di TipoRicoveroCodice NULL, uso codice N che non esiste
		AND ISNULL(ce.Messaggio.value('(/*/TipoRicoveroCodice)[1]', 'varchar(16)'), 'N') IN ('O', 'D', 'A')

		--2016-06-22 - Escludo ricoveri malformati (manca la A p.e.)
		AND ISNULL(ce.Messaggio.value('(/*/StatoRicoveroCodice)[1]', 'varchar(16)'), '0') <> '255'

		-- Esiste ancora
		-- 2017-11-06  oppure è una cancellazione
		AND (EXISTS (SELECT * FROM [store].[EventiBase] WHERE ID = ce.IdEvento)
			OR ce.Operazione = 2
			)

	ORDER BY ce.DataInvio
)