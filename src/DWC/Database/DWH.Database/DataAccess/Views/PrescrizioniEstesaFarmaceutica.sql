

CREATE VIEW [DataAccess].[PrescrizioniEstesaFarmaceutica]
/*
	CREATA DA SANDRO 2015-10-11: 
		Nuova vista ad uso esclusivo accesso ESTERNO
*/
AS
	SELECT IdPrescrizioniBase, DataPartizione, Riga, DataInserimento, DataModifica
		, InfoGenerali_Progressivo, InfoGenerali_Quantita, InfoGenerali_Posologia, InfoGenerali_Note
		, InfoGenerali_Classe, InfoGenerali_NotaAifa, InfoGenerali_NonSostituibile, InfoGenerali_CodMotivazioneNonSostituibile
		, Codifiche_AicSpecialita, Codifiche_MinSan10Specialita, Codifiche_DescSpecialita, Codifiche_CodGruppoTerapeutico
		, Codifiche_CodGruppoEquivalenza, Codifiche_DescGruppoEquivalenza
		, PercorsiRegionali_CodPercorsoRegionale, PercorsiRegionali_DescPercorsoRegionale, PercorsiRegionali_CodAziendaPercorsoRegionale
		, PercorsiRegionali_CodStrutturaPercorsoRegionale
	FROM store.PrescrizioniEstesaFarmaceutica WITH(NOLOCK)