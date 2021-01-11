

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-11-11
-- Modify date: 2017-11-06 Usa nuove function oscuramenti comuni
-- Modify date: 2017-11-06 ETTORE: Eliminazione logiche cablate: non controllo più se la diagnosi contiene HIV/sieropositiv e restituisco Confidenziale=0 sempre
-- Modify date: 2018-02-01 Valutazione confidenziale DSM
-- Modify date: 2019-01-22 Refactory, cambio schema
--
-- Description:	Ritorna lo stato di OSCURAMENTO dell'evento 
-- =============================================
CREATE FUNCTION [sole].[OttieniOscuramentiPerEvento]
(	
 @IdEvento UNIQUEIDENTIFIER
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT Id AS IdEvento

		-- CONFIDENZIALE
		,CASE WHEN SistemaErogante = 'EIM-ADTSTR' THEN 
								CONVERT(BIT, CASE ISNULL(UPPER(
										CONVERT(VARCHAR(64), dbo.GetEventiAttributo(Id, 'ConsensoPsi'))
															), '')
										WHEN 'Autorizza' THEN 0
										WHEN 'Non autorizza' THEN 1	WHEN 'Non in grado' THEN 1 WHEN 'Non rilevato' THEN 1
										ELSE 1 END)
				ELSE 0 END AS Confidenziale
	
		-- OSCURATO
		,CASE WHEN EXISTS (SELECT * FROM PazientiCancellati WITH(NOLOCK)
						WHERE PazientiCancellati.IdPazientiBase = Eventi.IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL) THEN 'Paziente'
						
			WHEN EXISTS (SELECT * FROM [dbo].[OttieniEventoOscuramenti](NULL, 'Puntuali', 'SOLE'
										,Eventi.AziendaErogante, Eventi.NumeroNosologico) ) THEN 'Evento'


			WHEN EXISTS (SELECT * FROM [dbo].[OttieniEventoOscuramenti](NULL, 'Massivi', 'SOLE'
										,Eventi.AziendaErogante, Eventi.NumeroNosologico) ) THEN 'Massivo'
		
			ELSE NULL END AS Oscurato	
		
	FROM [store].[Eventi] AS Eventi WITH(NOLOCK)
	WHERE Id = @IdEvento
)