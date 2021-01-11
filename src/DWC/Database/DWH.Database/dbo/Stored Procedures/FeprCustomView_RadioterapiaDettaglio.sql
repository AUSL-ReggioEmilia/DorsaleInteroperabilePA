
CREATE PROCEDURE [dbo].[FeprCustomView_RadioterapiaDettaglio]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
	SET NOCOUNT ON
/*
	Estrazione di tutte le prestazioni del referto
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store"
*/
	SELECT	Prestazioni.ID,
			--MODIFICA ETTORE 2012-09-10: traslo l'idpaziente nell'idpaziente attivo
			dbo.GetPazienteAttivoByIdSac(Referti.IDPaziente) AS IDPaziente,
			Referti.ID AS IdRefertiBase,

			Prestazioni.IdEsterno,
			Prestazioni.DataErogazione,
			Prestazioni.DataModifica,

			--Prestazioni.SezioneCodice,
			--Prestazioni.SezioneDescrizione,
			--Prestazioni.SezionePosizione,

			--LTRIM(RTRIM(Prestazioni.SezioneDescrizione)) + ' (' + Prestazioni.SezioneCodice + ') ' as Sezione,
			--Prestazioni.PrestazioneCodice,
			Prestazioni.PrestazioneDescrizione,

			Prestazioni.ValoriRiferimento,
			Convert(real,IsNull(dbo.GetPrestazioniAttributo( Prestazioni.Id, Prestazioni.DataPartizione, 'Quantita'),0)) as DoseErogata,
			CAST(ISNULL(dbo.GetPrestazioniAttributo(Prestazioni.Id, Prestazioni.DataPartizione, 'MachineIdDesc'),'') AS VARCHAR(50)) as MachineIdDesc,
			--
			-- Compilato da Reporting.Progel tramite aggregazione
			--
			'' AS DoseErogataTotale

	FROM 
		frontend.Referti AS Referti LEFT JOIN store.Prestazioni AS Prestazioni
			ON Referti.ID = Prestazioni.IDRefertiBase

	WHERE 	Referti.Id = @IdRefertiBase

	ORDER BY
		-- Prestazioni.SezionePosizione,
		-- Prestazioni.PrestazionePosizione,
			Prestazioni.DataErogazione desc


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprCustomView_RadioterapiaDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

