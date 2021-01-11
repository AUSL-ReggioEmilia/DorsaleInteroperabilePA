

CREATE VIEW [DataAccess].[PrescrizioniEstesaSpecialistica]
/*
	CREATA 2015-10-11:   SANDRO Nuova vista ad uso esclusivo accesso ESTERNO
	MODIFICA 2016-11-11: SANDRO Rimorra accentata InfoGenerali_Quantità
*/
AS
	SELECT IdPrescrizioniBase, DataPartizione, Riga, DataInserimento, DataModifica
		, InfoGenerali_Progressivo, InfoGenerali_Quantita, InfoGenerali_Note
		, InfoGenerali_CodBranca, InfoGenerali_TipoAccesso
		, Codifiche_CodDmRegionale, Codifiche_CodCatalogoRegionale, Codifiche_DescDmRegionale
		, Codifiche_DescCatalogoRegionale, Codifiche_CodAziendale, Codifiche_DescAziendale
		, PercorsiRegionali_CodPacchettoRegionale, PercorsiRegionali_CodPercorsoRegionale
		, PercorsiRegionali_DescPercorsoRegionale, PercorsiRegionali_CodAziendaPercorsoRegionale
		, PercorsiRegionali_CodStrutturaPercorsoRegionale
		, Dm915_Nota, Dm915_Erog, Dm915_Appr, Dm915_Pat
	FROM store.PrescrizioniEstesaSpecialistica WITH(NOLOCK)