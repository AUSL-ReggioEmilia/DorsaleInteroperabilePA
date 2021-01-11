

/*
	CREATA DA ETTORE 2015-07-01:
	Nuova vista che restituisce i referti associati alle sottoscrizioni
	I filtri "referto già in coda", per data ecc vengono applicati dalla SP
	cosi la vista può essere utilizzata a scopo di debug
	Utilizza la nuova vista store.Referti
	
	PROVATA IN PRODUZIONE: restituisce i referti modificati nelle ultime 2 ore in circa 8 secondi
*/
CREATE VIEW [dbo].[StampeSottoscrizioniReferti]
AS

		SELECT 
			Referti.ID AS IdReferto
			, Referti.DataModifica AS RefertiDataModifica
			, Referti.StatoRichiestaCodice AS RefertiStatoRichiestaCodice 
			, Sottoscr.Id AS IdStampeSottoscrizioni
			, Sottoscr.StampaConfidenziali 
			, Sottoscr.StampaOscurati
			--
			-- RefertiConfidenziale vale 1 sia per i referti con attributo "Confidenziale" che i referti che hanno la parola HIV nelle prestazioni
			--
			, CASE WHEN Referti.Confidenziale <> 0 OR dbo.GetRefertiHasPrestazioniHiv(Referti.Id, Referti.DataPartizione) <> 0 THEN
					CAST(1 AS BIT)
				ELSE
					CAST(0 AS BIT)
				END AS RefertiConfidenziale 			
			--
			-- RefertiOscuramento vale 1 solo per oscuramenti <> Confidenziale e per parola HIV
			--
			, CASE WHEN EXISTS (
						SELECT * FROM  dbo.GetRefertoOscuramenti(Referti.Id, Referti.DataPartizione, Referti.AziendaErogante
													, Referti.SistemaErogante, Referti.StrutturaEroganteCodice
													, Referti.NumeroNosologico, Referti.RepartoRichiedenteCodice
													, Referti.RepartoErogante, 0) --0, Referti.Confidenziale
									WHERE
										--Escludo gli oscuramenti per parola HIV
										CodiceOscuramento NOT IN (
										SELECT CodiceOscuramento FROM Oscuramenti WHERE TipoOscuramento = 8 AND Parola = 'HIV'
						)
				)
			THEN 1 ELSE 0 END AS RefertiOscuramento
		FROM 
			StampeSottoscrizioni AS Sottoscr
			INNER JOIN StampeSottoscrizioniRepartiRichiedenti AS SottoscrRepRich
				ON Sottoscr.Id = SottoscrRepRich.IdStampeSottoscrizioni
			INNER JOIN RepartiRichiedentiSistemiEroganti AS RepRichSistErog
				ON SottoscrRepRich.IdRepartiRichiedentiSistemiEroganti = RepRichSistErog.Id
			INNER JOIN store.Referti AS Referti
				ON Referti.RepartoRichiedenteCodice = RepRichSistErog.RepartoRichiedenteCodice
			INNER JOIN SistemiEroganti AS SistErog
				ON RepRichSistErog.IdSistemaErogante = SistErog.Id
					AND Referti.AziendaErogante = SistErog.AziendaErogante
					AND Referti.SistemaErogante = SistErog.SistemaErogante
		WHERE 
			(Referti.IdPaziente <> '00000000-0000-0000-0000-000000000000')
			--
			-- Applico tutti i filtri della vista frontend.referti
			--
			AND Referti.StatoRichiestaCodice <> 3	-- Non gli annullati
			--
			-- Verifico che non ci sia cancellazione totale per tutti i referti del paziente
			-- 
			AND NOT EXISTS (SELECT * FROM PazientiCancellati  
							WHERE PazientiCancellati.IdPazientiBase = Referti.IdPaziente) 
			--
			-- Nascondo gli oscuramenti PUNTUALI ??????????????
			--
			AND dbo.GetRefertoOscuramentiPuntuali(Referti.IdEsterno, Referti.AziendaErogante, Referti.SistemaErogante
							, Referti.NumeroNosologico, Referti.NumeroPrenotazione
							, Referti.NumeroReferto, Referti.IdOrderEntry) = 0

GO
GRANT SELECT
    ON OBJECT::[dbo].[StampeSottoscrizioniReferti] TO [ExecuteService]
    AS [dbo];

