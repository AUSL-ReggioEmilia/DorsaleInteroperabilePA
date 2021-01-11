






-- =============================================
-- Author:		ETTORE
-- Create date: 2016-03-17: AD uso esclusivo dei WS-DWH-WCF
-- Description:	Restituisce i dati da visualizzare nei metodi di lista referti dei WS3
-- Modify date: ETTORE: 2017-10-31: restituiti gli attributi relativi all'esito dell'invio SOLE del referto
					--Esito = 'Sole-EsitoInvio' puo contenere AA, AE, AR
					--Data = 'Sole-DataInvio' datatime con T
-- Modify date: ETTORE: 2020-05-12: restituiti campi letti dagli attributi per nuovi campi relativi a task [7758,5754]
-- Modify date: ETTORE: 2020-06-09: Modificato il nome dell'attributo per le avvertenze in "Dwh@Avvertenze"
-- Modify date: ETTORE: 2020-06-12: Aggiunto l'attributo "Dwh@AvvertenzeSeverita"
-- Modify date: ETTORE: 2020-12-28: Modificato il nome degli attributi "Sole": 'Sole' -> '$@Sole' perchè divenuti attributi persistenti
-- =============================================
CREATE VIEW [ws3].[Referti]
AS
SELECT  
	ID,
	DataPartizione,
	IdEsterno,
	IdPaziente,
	DataInserimento,
	DataModifica,
	AziendaErogante,
	SistemaErogante,
	RepartoErogante,
	DataReferto,
	DataEvento,
	NumeroReferto,
	NumeroNosologico,
	NumeroPrenotazione,
	IdOrderEntry,
	Firmato,
	RepartoRichiedenteCodice,
	RepartoRichiedenteDescr,
	StatoRichiestaCodice,
	dbo.GetRefertoStatoDesc(RepartoErogante, 
					CONVERT(VARCHAR(16), StatoRichiestaCodice),
					StatoRichiestaDescr
				) AS StatoRichiestaDescr,
	CAST(NomeStile AS VARCHAR(64)) AS NomeStile,	
	
	Cognome,
	Nome,
	Sesso,
	CodiceFiscale,
	DataNascita,
	ComuneNascita,
	CodiceSanitario,
	
	PrioritaCodice,
	PrioritaDescr,
	TipoRichiestaCodice,
	TipoRichiestaDescr,
	Referto,
	MedicoRefertanteCodice,
	MedicoRefertanteDescr,
	SpecialitaErogante,
	StrutturaEroganteCodice, 
	Confidenziale,
	Anteprima,
	CONVERT(VARCHAR(2), dbo.GetRefertiAttributo2(Id, DataPartizione, '$@Sole-EsitoInvio')) AS SoleEsitoInvio
	,dbo.GetRefertiAttributo2DateTime(Id, DataPartizione, '$@Sole-DataInvio') AS SoleDataInvio

	--MODIFICA ETTORE: 2020-05-12: restituiti campi letti dagli attributi per nuovi campi relativi a task [7758,5754]
	, CONVERT(INTEGER, dbo.GetRefertiAttributo2(Id, DataPartizione, '$@NumeroVersione')) AS NumeroVersione
	, CONVERT(VARCHAR(MAX), dbo.GetRefertiAttributo2(Id, DataPartizione, 'Dwh@Avvertenze')) AS Avvertenze
	, CONVERT(TINYINT, dbo.GetRefertiAttributo2(Id, DataPartizione, 'Dwh@AvvertenzeSeverita')) AS AvvertenzeSeverita

FROM 
	store.Referti
WHERE
	--ATTENZIONE: nella vista dbo.RefertiWS veniva restituito anche un ruolo di visualizzazione per gli Annullati
	StatoRichiestaCodice <> 3	-- Non gli annullati
	--
	-- Verifico che non ci sia cancellazione totale per tutti i referti del paziente
	-- 
	AND NOT EXISTS (SELECT * FROM PazientiCancellati  
					WHERE PazientiCancellati.IdPazientiBase = IdPaziente
						AND PazientiCancellati.IdRepartiEroganti IS NULL) --toglieremo il campo IdRepartiEroganti dalla tabella PazientiCancellati  
	--
	-- Nascondo gli oscuramenti PUNTUALI
	--
	AND dbo.GetRefertoOscuramentiPuntuali(IdEsterno, AziendaErogante, SistemaErogante
					, NumeroNosologico, NumeroPrenotazione
					, NumeroReferto, IdOrderEntry) = 0