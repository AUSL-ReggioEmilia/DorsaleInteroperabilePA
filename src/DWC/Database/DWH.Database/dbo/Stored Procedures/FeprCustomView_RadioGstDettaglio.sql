


-- =============================================
-- Author:		
-- Create date: 
-- Description:	SP per il dettaglio referto di radiologia per stile RadioGST.01.00
-- Modify date: 2020-12-14 - Modificato per la restituzione degli accession number separati da '\\' invece che da ';'
--							per apertura PACS con VUE (BackLog Item: 'Portale DWH: Modifica invocazione PACS da DWH [9042]')
-- =============================================
CREATE PROCEDURE dbo.FeprCustomView_RadioGstDettaglio
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
SET NOCOUNT ON
/* 
	Estrazione di tutte le prestazioni del referto
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store"
*/

SELECT	
	Prestazioni.ID,
	--MODIFICA ETTORE 2012-09-10: traslo l'idpaziente nell'idpaziente attivo
	dbo.GetPazienteAttivoByIdSac(Referti.IDPaziente) AS IDPaziente,
	Referti.ID AS IdRefertiBase,

	Prestazioni.IdEsterno,
	Prestazioni.DataErogazione,
	Prestazioni.DataModifica,

	Prestazioni.SezioneCodice,
	Prestazioni.SezioneDescrizione,

	LTRIM(RTRIM(Prestazioni.SezioneDescrizione)) + ' (' + Prestazioni.SezioneCodice + ') ' as Sezione,
	Prestazioni.PrestazioneCodice,
	Prestazioni.PrestazioneDescrizione,

	--MODIFICA ETTORE 2020-12-14: Replace dei caratteri ';' con '\\'
	REPLACE(CONVERT(VARCHAR (64),dbo.GetPrestazioniAttributo( Prestazioni.Id, Prestazioni.DataPartizione, 'AccessionNumber')), ';', '\\') as AccessNumber
FROM 
	frontend.Referti AS Referti
	LEFT JOIN store.Prestazioni AS Prestazioni
		ON Referti.ID = Prestazioni.IDRefertiBase
WHERE 	
	Referti.Id = @IdRefertiBase
ORDER BY 
	Prestazioni.SezionePosizione,
	Prestazioni.PrestazionePosizione

SET NOCOUNT OFF


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprCustomView_RadioGstDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

