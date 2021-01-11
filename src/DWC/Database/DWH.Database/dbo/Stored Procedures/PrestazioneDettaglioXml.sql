
-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE PROCEDURE [dbo].[PrestazioneDettaglioXml] 
                @IdRefertiBase AS uniqueidentifier
AS

IF NOT @IdRefertiBase IS NULL
                --
                -- Solo per i dati
                --
                SELECT Prestazione.Id, Prestazione.DataErogazione, 
                               Prestazione.PrestazioneCodice, Prestazione.PrestazioneDescrizione, 
                               Prestazione.SezioneCodice, Prestazione.SezioneDescrizione,
                               Attributo.Nome, Attributo.Valore
                FROM store.PrestazioniBase AS Prestazione INNER JOIN store.PrestazioniAttributi AS Attributo
                               ON Prestazione.Id =  Attributo.IdPrestazioniBase
                               AND Prestazione.DataPartizione = Attributo.DataPartizione
                WHERE Prestazione.IdRefertiBase = @IdRefertiBase
                ORDER BY  Prestazione.PrestazioneCodice, Attributo.Nome
                FOR XML AUTO, ELEMENTS
ELSE
                --
                -- Solo per lo schema
                --
                SELECT Prestazione.Id, Prestazione.DataErogazione, 
                               Prestazione.PrestazioneCodice, Prestazione.PrestazioneDescrizione, 
                               Prestazione.SezioneCodice, Prestazione.SezioneDescrizione,
                               Attributo.Nome, Attributo.Valore
                FROM store.PrestazioniBase AS Prestazione INNER JOIN store.PrestazioniAttributi AS Attributo
                               ON Prestazione.Id =  Attributo.IdPrestazioniBase
                               AND Prestazione.DataPartizione = Attributo.DataPartizione
                WHERE 1=2
                FOR XML AUTO, ELEMENTS, XMLDATA


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PrestazioneDettaglioXml] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PrestazioneDettaglioXml] TO [ExecuteSole]
    AS [dbo];

