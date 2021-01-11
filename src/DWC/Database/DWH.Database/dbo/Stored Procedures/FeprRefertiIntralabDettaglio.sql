
CREATE PROCEDURE [dbo].[FeprRefertiIntralabDettaglio]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
/*
	Estrazione di tutte le prestazioni per il referto passato
	Questa ST viene usata anche nel repor di batteriologia, quindi escludo
	tutti quei record che riguardano batteriologia che sarebbero comunque incomprensibili
	
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
		--Prestazioni.RunningNumber, --ORIGINALE, ma la vista store.Prestazioni non lo restituisce
		dbo.GetPrestazioniAttributoInteger( Prestazioni.Id, Prestazioni.DataPartizione, 'RunningNumber') as RunningNumber,
		Prestazioni.GravitaCodice,
		Prestazioni.GravitaDescrizione,
		Prestazioni.Risultato,
		Prestazioni.ValoriRiferimento,
		Prestazioni.SezionePosizione,
		Prestazioni.PrestazionePosizione,
		--Prestazioni.Commenti
		--
		-- NUOVO
		-- I commenti ad una prestazione vengono posti negli attributi nell'attributo PrestCommento
		-- Per vecchi referti si trova anche in Prestazioni.Commenti
		--
		ISNULL(Prestazioni.Commenti,CAST(TabPrestCommento.Valore as varchar(1024))) AS Commenti

	FROM	
		frontend.Referti AS Referti
		LEFT JOIN store.Prestazioni AS Prestazioni ON Referti.ID = Prestazioni.IDRefertiBase
		----nuova per avere il commento in riga
		LEFT JOIN store.PrestazioniAttributi AS TabPrestCommento 
				ON TabPrestCommento.IdPrestazioniBase = Prestazioni.ID 
				   AND TabPrestCommento.Nome = 'PrestCommento' 

		--nuovo per avere in riga l'ordinamento principale
		LEFT OUTER JOIN store.PrestazioniAttributi AS TabPrestGruppoPrio  on TabPrestGruppoPrio.IdPrestazioniBase = Prestazioni.Id
						AND TabPrestGruppoPrio.Nome = 'PrestGruppoPrio'
		--nuovo per filtrare tutto ciò che non è di batteriologia
		LEFT OUTER JOIN store.PrestazioniAttributi AS TabPrestTipo on TabPrestTipo.IdPrestazioniBase = Prestazioni.Id
						AND TabPrestTipo.Nome = 'PrestTipo'


	WHERE 	
		Referti.ID = @IdRefertiBase
		--
		-- Elimino tutte quelle prestazioni che sono proprie della batteriologia 
		--
		--solo i dati che non sono di batteriologia
		AND
		NOT (CAST(ISNULL(TabPrestTipo.valore,'C') as varchar(10)) = 'M')

	ORDER BY 	
		CAST(TabPrestGruppoPrio.valore as varchar(1024))
		,Prestazioni.SezionePosizione
		,Prestazioni.SezioneCodice 
		,Prestazioni.PrestazionePosizione 
		,Prestazioni.PrestazioneCodice 


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiIntralabDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

