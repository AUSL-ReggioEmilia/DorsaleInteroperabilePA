
CREATE PROCEDURE [dbo].[FeprRefertiRadionetDettaglio]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
/*
	Estrazione di tutte le prestazioni del referto
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store" 
*/
	SET NOCOUNT ON
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
		Convert(varchar (64),dbo.GetPrestazioniAttributo( Prestazioni.Id, Prestazioni.DataPartizione,  'AccessNumber')) as AccessNumber
	FROM		
		frontend.Referti AS Referti
		LEFT JOIN store.Prestazioni AS Prestazioni 
			ON Referti.ID = Prestazioni.IDRefertiBase
	WHERE 	
		Referti.Id = @IdRefertiBase
	ORDER BY	
		Prestazioni.SezionePosizione, 
		Prestazioni.PrestazionePosizione


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiRadionetDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

