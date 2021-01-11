

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-11-11
-- Modify date: 2017-11-09 Usa nuove function oscuramenti comuni
-- Modify date: 2018-02-01 Valutazione confidenziale DSM
-- Modify date: 2019-01-22 Refactoring cambio schema
--
-- Description:	Ritorna lo stato di OSCURAMENTO del referto 
-- =============================================
CREATE FUNCTION [sole].[OttieniOscuramentiPerReferto]
(	
 @IdReferto UNIQUEIDENTIFIER
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT Id AS IdReferto
	
			-- CONFIDENZIALE
			-- Per DSM valuta un altro attributo
			,CASE WHEN SistemaErogante = 'EIM-LDDDSM' OR SistemaErogante = 'EIM-REFDSM' THEN 
								CONVERT(BIT, CASE ISNULL(UPPER(
										CONVERT(VARCHAR(64), dbo.GetRefertiAttributo2(Id, DataPartizione, 'ConsensoPsi'))
															), '')
										WHEN 'Autorizza' THEN 0
										WHEN 'Non autorizza' THEN 1	WHEN 'Non in grado' THEN 1 WHEN 'Non rilevato' THEN 1
										ELSE 1 END)
				ELSE Referti.Confidenziale END AS Confidenziale
	
			-- OSCURATO	
			,CASE 
				-- Cancellato paziente
				WHEN EXISTS (SELECT * FROM PazientiCancellati WITH(NOLOCK)
							WHERE PazientiCancellati.IdPazientiBase = Referti.IdPaziente
								AND PazientiCancellati.IdRepartiEroganti IS NULL) THEN 'Paziente'
			
				-- Oscuramento puntuale
				WHEN EXISTS (SELECT * FROM [dbo].[OttieniRefertoOscuramenti](NULL, 'Puntuali', 'SOLE'
											,Referti.IdEsterno, NULL, NULL
											,Referti.AziendaErogante, Referti.SistemaErogante, Referti.NumeroNosologico
											,Referti.NumeroPrenotazione, Referti.NumeroReferto, Referti.IdOrderEntry
											,NULL, NULL, NULL, NULL) ) THEN 'Referto'

				-- Oscuramento massivo (in visualizzazione dipende dal RUOLO)
				WHEN EXISTS ( SELECT *	FROM [dbo].[OttieniRefertoOscuramenti](NULL, 'Massivi', 'SOLE'
											,NULL, Referti.Id, Referti.DataPartizione
											,Referti.AziendaErogante, Referti.SistemaErogante, Referti.NumeroNosologico
											,NULL, NULL, NULL, Referti.StrutturaEroganteCodice
											,Referti.RepartoRichiedenteCodice, Referti.RepartoErogante 
											,Referti.Confidenziale) ) THEN 'Massivo'

				ELSE NULL END AS Oscurato
		
	FROM [store].[Referti] AS Referti WITH(NOLOCK)
	WHERE Id = @IdReferto
)