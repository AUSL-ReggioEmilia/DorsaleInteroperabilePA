
CREATE PROCEDURE [dbo].[FeprRefertiSdoDettaglio]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
/*
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store" 
*/
	SET NOCOUNT ON
	SELECT	
		Prestazioni.ID,
		--MODIFICA ETTORE 2012-09-10: traslo l'idpaziente nell'idpaziente attivo
		dbo.GetPazienteAttivoByIdSac(Referti.IDPaziente) AS IDPaziente,
		Referti.ID AS IdRefertiBase,
		Prestazioni.DataErogazione,
		Prestazioni.DataModifica,
		Prestazioni.SezioneCodice,
		Prestazioni.SezioneDescrizione,
--		LTRIM(RTRIM(Prestazioni.SezioneDescrizione)) + ' (' + Prestazioni.SezioneCodice + ') ' as Sezione,
		CASE Prestazioni.SezioneCodice
			WHEN 'C' THEN 'Procedure'
			WHEN 'M' THEN 'Diagnosi'
			ELSE Prestazioni.SezioneDescrizione
		END AS Sezione,
		'(' + Prestazioni.PrestazioneCodice + ') ' + Prestazioni.PrestazioneDescrizione AS PrestazioneDescrizione,
		null AS NomeFile,
		--Prestazioni.RunningNumber, --ORIGINALE, ma la vista store.Prestazioni non lo restituisce
		dbo.GetPrestazioniAttributoInteger( Prestazioni.Id, Prestazioni.DataPartizione, 'RunningNumber') as RunningNumber,
		Prestazioni.GravitaCodice,
		Prestazioni.GravitaDescrizione,
		Prestazioni.Risultato,
		Prestazioni.ValoriRiferimento,
		Prestazioni.Commenti,
		1 as TipoDettaglio,
		Prestazioni.SezionePosizione,
		Prestazioni.PrestazionePosizione
	FROM		
		frontend.Referti AS Referti
		INNER JOIN store.Prestazioni AS Prestazioni
			ON Referti.ID = Prestazioni.IDRefertiBase
	WHERE 	
		Referti.ID = @IdRefertiBase

	UNION

	SELECT	
		Allegati.ID,
		--MODIFICA ETTORE 2012-09-10: traslo l'idpaziente nell'idpaziente attivo
		dbo.GetPazienteAttivoByIdSac(Referti.IDPaziente) AS IDPaziente,
		Referti.ID AS IdRefertiBase,
		Allegati.DataFile DataErogazione,
		Allegati.DataModifica,
		null as SezioneCodice,
		'Allegato' as SezioneDescrizione,
		'Allegato' as Sezione,
		null as PrestazioneDescrizione,
		Allegati.NomeFile as NomeFile,
		null as RunningNumber,
		null as GravitaCodice,
		null as GravitaDescrizione,
		null as Risultato,
		null as ValoriRiferimento,
		Allegati.Descrizione as Commenti,
		0 as TipoDettaglio,
		0 as SezionePosizione,
		Allegati.Posizione as PrestazionePosizione
	FROM		
		frontend.Referti 
		INNER JOIN store.Allegati 
			ON Referti.ID = Allegati.IDRefertiBase
	WHERE 	
		Referti.ID = @IdRefertiBase

	ORDER BY	
		TipoDettaglio, SezionePosizione, PrestazionePosizione


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiSdoDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

