
-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE PROCEDURE [dbo].[RefertoDettaglioXml]
                @ID AS uniqueidentifier
AS
                IF NOT @ID IS NULL
                               --
                               -- Solo per i dati
                               --
                               SELECT Referto.Id,  Referto.AziendaErogante, 
                                               Referto.SistemaErogante, Referto.RepartoErogante, 
                                               Referto.DataReferto, Referto.NumeroReferto, 
                                               Referto.NumeroPrenotazione, Referto.NumeroNosologico,
                                               Attributo.Nome, Attributo.Valore
                               FROM store.RefertiBase AS Referto INNER JOIN store.RefertiAttributi AS Attributo
                                               ON Referto.Id = Attributo.IdRefertiBase
                                               AND Referto.DataPartizione = Attributo.DataPartizione
                               WHERE Referto.Id = @ID
                               FOR XML AUTO, ELEMENTS
                ELSE
                               --
                               -- Solo per lo schema
                               --
                               SELECT Referto.Id,  Referto.AziendaErogante, 
                                               Referto.SistemaErogante, Referto.RepartoErogante, 
                                               Referto.DataReferto, Referto.NumeroReferto, 
                                               Referto.NumeroPrenotazione, Referto.NumeroNosologico,
                                               Attributo.Nome, Attributo.Valore
                               FROM store.RefertiBase AS Referto INNER JOIN store.RefertiAttributi AS Attributo
                                               ON Referto.Id = Attributo.IdRefertiBase
                                               AND Referto.DataPartizione = Attributo.DataPartizione
                               WHERE 1=2
                               FOR XML AUTO, ELEMENTS, XMLDATA


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[RefertoDettaglioXml] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[RefertoDettaglioXml] TO [ExecuteSole]
    AS [dbo];

