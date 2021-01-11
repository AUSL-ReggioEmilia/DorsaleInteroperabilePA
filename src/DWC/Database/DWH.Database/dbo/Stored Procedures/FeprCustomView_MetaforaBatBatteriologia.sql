
CREATE PROCEDURE [dbo].[FeprCustomView_MetaforaBatBatteriologia]
(
	@IdRefertiBase as uniqueidentifier 
)
 AS
/*
	Ritorna i dati associati ad un referto di Metafora batteriologia
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store"
*/
SET NOCOUNT ON
	SELECT	
			Referti.Id AS IdRefertiBase,
			NULL AS DataRefertoInizioItaliano,
			Referti.DataReferto,
			Referti.NumeroReferto,
			Convert(VarChar(20), Referti.DataReferto, 103) AS DataRefertoItaliano,
			Referti.SistemaErogante,
			Referti.RepartoErogante,
			--PER COMPATIBILITA
			'' AS RepartoRichiedenteRuoloVisualizzazione,
			'' AS RuoloVisualizzazioneRepartoRichiedente,
			'' AS RuoloVisualizzazioneSistemaErogante,

			Prestazioni.ID AS IdPrestazioni,
			Prestazioni.SezionePosizione,
			Prestazioni.SezioneCodice,
			LTRIM(RTRIM(Prestazioni.SezioneDescrizione)) as SezioneDescrizione,
			CAST(ISNULL(TabPrestGruppoPrio.valore,'0') as varchar(1024))as PrestGruppoPrio,
			--C=dati di laboratorio, M=dati di batteriologia/microbiologia
			CAST(ISNULL(TabPrestTipo.valore,'C') as varchar(10))as PrestPrestTipo,
			Prestazioni.PrestazionePosizione,
			Prestazioni.PrestazioneCodice,
			Prestazioni.PrestazioneDescrizione,
			COALESCE( NULLIF(Prestazioni.Risultato, ''), Prestazioni.Commenti) AS Risultato,
			ISNULL(Prestazioni.ValoriRiferimento,'') AS ValoriRiferimento,
			Prestazioni.Commenti,
			--I campi da cui ricavare le coppie Nome/Valore per le prestazioni
			PrestazioniAttributi.Nome as NomeAttributo,
			CAST(PrestazioniAttributi.valore as varchar(1024)) as ValoreAttributo
	FROM		
			frontend.Referti 
			LEFT OUTER JOIN store.Prestazioni ON Referti.ID = Prestazioni.IDRefertiBase
			LEFT OUTER JOIN store.PrestazioniAttributi on store.PrestazioniAttributi.IdPrestazioniBase = Prestazioni.Id
			--Per avere in riga l'ordinamento principale
			LEFT OUTER JOIN store.PrestazioniAttributi AS TabPrestGruppoPrio (nolock ) on TabPrestGruppoPrio.IdPrestazioniBase = Prestazioni.Id
							AND TabPrestGruppoPrio.Nome = 'PrestGruppoPrio'
			--Per avere in riga il tipo di dato
			LEFT OUTER JOIN store.PrestazioniAttributi AS TabPrestTipo (nolock ) on TabPrestTipo.IdPrestazioniBase = Prestazioni.Id
							AND TabPrestTipo.Nome = 'PrestTipo'
	WHERE	
			(Referti.Id = @IdRefertiBase)
			AND
			(ISNULL(Prestazioni.Risultato,'') <> 'non refertabile')		
			AND
			--solo dati di batteriologia/microbiologia
			CAST(ISNULL(TabPrestTipo.valore,'C') as varchar(10)) = 'M' 

	ORDER BY 	
			CAST(TabPrestGruppoPrio.valore as varchar(1024))
			,Prestazioni.SezionePosizione
			,Prestazioni.SezioneCodice 
			,Prestazioni.PrestazionePosizione 
			,Prestazioni.PrestazioneCodice 


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprCustomView_MetaforaBatBatteriologia] TO [ExecuteFrontEnd]
    AS [dbo];

