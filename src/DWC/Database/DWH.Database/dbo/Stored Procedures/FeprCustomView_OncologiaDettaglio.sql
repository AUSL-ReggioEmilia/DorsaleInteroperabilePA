
CREATE PROCEDURE [dbo].[FeprCustomView_OncologiaDettaglio]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
SET NOCOUNT ON
/*
	Estrazione di tutte le prestazioni per il referto passato
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store"
*/
	SELECT	
		Prestazioni.ID,
		--MODIFICA ETTORE 2012-09-10: traslo l'id paziente nell'id paziente attivo
		dbo.GetPazienteAttivoByIdSac(Referti.IDPaziente) AS IDPaziente,
		Referti.ID AS IdRefertiBase,
		Prestazioni.DataModifica,
		Prestazioni.DataErogazione,
		CONVERT(VARCHAR(12), dbo.GetPrestazioniAttributo( Prestazioni.Id, Prestazioni.DataPartizione, 'NUMEROCICLI') ) AS NumeroCicli,
		Prestazioni.PrestazioneCodice,
		Prestazioni.PrestazioneDescrizione
	FROM  
		frontend.Referti 
		INNER JOIN store.Prestazioni AS Prestazioni
			ON Referti.ID = Prestazioni.IDRefertiBase
	WHERE  
		Referti.ID = @IdRefertiBase
	ORDER BY 
		Prestazioni.DataErogazione
	

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprCustomView_OncologiaDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

