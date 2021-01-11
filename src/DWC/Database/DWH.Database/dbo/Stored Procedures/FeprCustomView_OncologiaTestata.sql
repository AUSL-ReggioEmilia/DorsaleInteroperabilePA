
CREATE PROCEDURE [dbo].[FeprCustomView_OncologiaTestata]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
/* 
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store"
	Usato dbo.GetRefertiAttributo2DateTime
*/
	SET NOCOUNT ON
	SELECT ID,
		IdEsterno,
		--MODIFICA ETTORE 2012-09-10: traslo l'idpaziente nell'idpaziente attivo
		dbo.GetPazienteAttivoByIdSac(IdPaziente) AS IdPaziente,

		DataInserimento,
		DataModifica,

		AziendaErogante,
		SistemaErogante,
		RepartoErogante,

		CONVERT(VARCHAR(20), DataReferto, 103) AS DataReferto,

		CONVERT(VARCHAR(12), dbo.GetRefertiAttributo2DateTime(Id, DataPartizione, 'DATAINIZIO'), 103) AS DataInizio,
		
		CONVERT(VARCHAR(12), dbo.GetRefertiAttributo2DateTime(Id, DataPartizione, 'DATAFINE'), 103) AS DataFine,
		
		NumeroReferto,

		Cognome,
		Nome,
		CodiceFiscale,
		CONVERT(VARCHAR(20), DataNascita, 103) AS DataNascita,
		ComuneNascita,

		RepartoRichiedenteCodice,
		RepartoRichiedenteDescr,
		RepartoRichiedenteDescr + ' (' + RepartoRichiedenteCodice + ')' AS RepartoRichiedente,

		StatoRichiestaCodice,
		StatoRichiestaDescr

	FROM  
		frontend.Referti
	WHERE 
		Id = @IdRefertiBase


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprCustomView_OncologiaTestata] TO [ExecuteFrontEnd]
    AS [dbo];

