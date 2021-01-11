
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 

--MODIFICA ETTORE 2015-02-03: 
--	1)	Sostituita la vista RefertiTutti con la tabella RefertiBase
--	2)	Viene restituito se il referto è OSCURATO (attraverso tabella Oscuramenti)
--	3)	Utilizzo delle nuove function dbo.GetRefertiAttributo2() e dbo.GetRefertiAttributo2DateTime()
		
--MODIFICA STEFANO 2015-03-03 Sostituita chiamata a GetRefertiAttributo2
--MODIFICA SANDRO 2015-08-19 Usa store.Allegati e store.Prestazioni
-- Modify date: 2016-05-11 sandro - Usa nuova func [sac].[OttienePazientePerIdSac]
--
-- Description:	Restituisce  il dettaglio del referto
-- =============================================

CREATE PROCEDURE [dbo].[FeAdminRefertoDettaglio]
	@IdReferto as uniqueidentifier
 AS
BEGIN
	SET NOCOUNT ON
	--
	-- @IdReferto obbligatorio
	--
	IF @IdReferto IS NULL
		RAISERROR ('Error @IdReferto non può essere nullo!', 16 ,1 )
 	--
	-- Query del dettaglio
	--
	SELECT TOP 1000
		  R.Id
		, R.IdEsterno
		, R.AziendaErogante
		, R.SistemaErogante
		, R.RepartoErogante

		, ISNULL(P.Nome + ' ', '') + ISNULL(P.Cognome + ' ', ' ') + ISNULL(' (' + P.Sesso + ')', '') + CONVERT(VARCHAR(2), 0x0D0A)
		+ ISNULL(CONVERT(VARCHAR(10),P.DataNascita, 101) + ' ', '') + ISNULL(' (' + P.LuogoNascitaDescrizione + ')', '') + CONVERT(VARCHAR(2), 0x0D0A)
		+ ISNULL(P.CodiceFiscale + ' ', '') AS PazienteSac 
		, P.Id AS IdSac

		, R.DataInserimento
		, R.DataModifica
		, R.DataReferto
		, R.NumeroReferto
		, R.NumeroNosologico
		, R.NumeroPrenotazione

		, ISNULL(R.Nome  + ' ', '')
		+ ISNULL(R.Cognome  + ' ', ' ')
		+ ISNULL(' (' + R.Sesso + ')', '')
		+ CONVERT(VARCHAR(2), 0x0D0A) 
		+ ISNULL(CONVERT(VARCHAR(10), R.DataNascita , 101) + ' ', '') 
		+ ISNULL(' (' + R.ComuneNascita + ')', '')  
		+ CONVERT(VARCHAR(2), 0x0D0A)
		+ ISNULL(R.CodiceFiscale + ' ', '') 
		AS PazienteReferto

		, ISNULL(R.RepartoRichiedenteDescr +' ', '') 
		+ ISNULL(' (' + R.RepartoRichiedenteCodice + ')', '') 
		AS RepartoRichiedente

		, ISNULL(dbo.GetRefertoStatoDesc(R.RepartoErogante, 
					CONVERT(VARCHAR(16), R.StatoRichiestaCodice),
					R.StatoRichiestaDescr 
				) + ' ', '') 
		+ ISNULL(' (' + CONVERT(VARCHAR(16), R.StatoRichiestaCodice) + ')', '')
		AS StatoRichiesta

		, ISNULL(R.PrioritaDescr + ' ', '')
		+ ISNULL(' (' + R.PrioritaCodice + ')', '')
		AS Priorita

		, ISNULL(R.TipoRichiestaDescr +' ', '') 
		+ ISNULL(' (' + R.TipoRichiestaCodice + ')', '')
		AS TipoRichiesta
		    
		, R.Referto

		, ISNULL(R.MedicoRefertanteDescr +' ', '')
		+ ISNULL(' (' + R.MedicoRefertanteCodice + ')', '')
		AS MedicoRefertante

		, 'Apri referto sul DwhClinico' AS ApriDwhClinico

		, 'Apri log invio SOLE' AS ApriSOLE

		, (SELECT CASE COUNT(*) WHEN 0 THEN ''
							 ELSE 'Apri allegati (' + CONVERT(VARCHAR(4), COUNT(*)) + ')' END
			FROM store.AllegatiBase AS AB WITH(NOLOCK)
			WHERE AB.IdRefertiBase = R.ID) AS ApriAllegati

		, (SELECT CASE COUNT(*) WHEN 0 THEN ''
							 ELSE 'Apri Prestazioni (' + CONVERT(VARCHAR(4), COUNT(*)) + ')' END
			FROM store.PrestazioniBase AS PB WITH(NOLOCK)
			WHERE PB.IdRefertiBase = R.ID) AS ApriPrestazioni
			
		, R.NomeStile
		
		--Restituisce se oscurato
		, CASE WHEN LEN(
				ISNULL(dbo.GetRefertoCodiciOscuramento2
					(
						R.Id,  
						R.IdEsterno,  
						R.DataPartizione,
						R.AziendaErogante,
						R.SistemaErogante,
						R.StrutturaEroganteCodice,
						R.NumeroNosologico,
						R.RepartoRichiedenteCodice,
						R.RepartoErogante,
						R.NumeroPrenotazione,
						R.NumeroReferto,
						R.IdOrderEntry,
						R.Confidenziale
					) , '') 
				)  > 0 THEN CAST(1 AS BIT)
			ELSE
				CAST(0 AS BIT)
			END AS Oscurato
  
	FROM store.Referti AS R WITH(NOLOCK)
		CROSS APPLY [sac].[OttienePazientePerIdSac](R.IdPaziente) P

	WHERE R.Id = @IdReferto
  
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeAdminRefertoDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

