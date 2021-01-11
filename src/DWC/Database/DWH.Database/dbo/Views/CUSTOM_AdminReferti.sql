




CREATE VIEW [dbo].[CUSTOM_AdminReferti]
AS
/*
	MODIFICA ETTORE 2015-03-03: uso delle function GetRefertiAttributo2() e GetRefertiAttributo2DateTime()
*/
	SELECT 
		r.ID,
		r.IdEsterno,
		r.IdPaziente,
		r.DataInserimento,
		r.DataModifica,
		r.AziendaErogante,
		r.SistemaErogante,
		r.RepartoErogante,
		r.DataReferto,
		r.NumeroReferto,
		r.NumeroNosologico,
		r.NumeroPrenotazione,

		p.Cognome AS Cognome,
		p.Nome AS Nome,
		p.CodiceFiscale AS CodiceFiscale,
		p.DataNascita AS DataNascita,
		p.ComuneNascitaNome AS ComuneNascita,
		p.Tessera AS CodiceSanitario,
		
		--MODIFICA ETTORE 2014-06-16: NomeStile da VARCHAR(15) a VARCHAR(64)
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2( r.Id, r.DataPartizione, 'NomeStile')) AS NomeStile,
		
		RepartoRichiedenteCodice,
		RepartoRichiedenteDescr,

		CONVERT(VARCHAR(16), r.StatoRichiestaCodice) AS StatoRichiestaCodice,
		
		dbo.GetRefertoStatoDesc(r.RepartoErogante, StatoRichiestaCodice,
						CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(r.Id, r.DataPartizione, 'StatoRichiestaDescr')) 
					) AS StatoRichiestaDescr,

		CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2(r.Id, r.DataPartizione, 'PrioritaCodice')) AS PrioritaCodice,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(r.Id, r.DataPartizione, 'PrioritaDescr')) AS PrioritaDescr,

		CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2(r.Id, r.DataPartizione, 'TipoRichiestaCodice')) AS TipoRichiestaCodice,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(r.Id, r.DataPartizione, 'TipoRichiestaDescr')) AS TipoRichiestaDescr,

		CONVERT(VARCHAR(8000), dbo.GetRefertiAttributo2(r.Id, r.DataPartizione, 'Referto')) AS Referto
		
	FROM store.RefertiBase r WITH(NOLOCK)
		INNER JOIN dbo.[SAC_Pazienti] p WITH(NOLOCK)
		--INNER JOIN dbo.PazientiBase p WITH(NOLOCK)
			ON r.IdPaziente = p.Id




GO
GRANT SELECT
    ON OBJECT::[dbo].[CUSTOM_AdminReferti] TO [ExecuteFrontEnd]
    AS [dbo];

