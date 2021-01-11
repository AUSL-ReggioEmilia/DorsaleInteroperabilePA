
CREATE VIEW [dbo].[Prestazioni]
AS
/*
	Tutti gli PRESTAZIONI a livello di singlo STORE
		Rimossi: RunningNumber
	
	NUOVA SANDRO 2015-05-13: Copiata da PrestazioniTutte
*/
	SELECT ID
		,DataPartizione
		,IdRefertiBase
		,IdEsterno
		,DataInserimento
		,DataModifica
		,DataErogazione
		,PrestazioneCodice
		,PrestazioneDescrizione
		,SoundexPrestazione
		,SezioneCodice
		,SezioneDescrizione
		,SoundexSezione

		,CONVERT(VARCHAR(1),dbo.GetPrestazioniAttributo2(Id, DataPartizione, 'GravitaCodice')) as GravitaCodice
		,CONVERT(VARCHAR(50),dbo.GetPrestazioniAttributo2(Id, DataPartizione, 'GravitaDescrizione')) as GravitaDescrizione
		,CONVERT(VARCHAR(255),dbo.GetPrestazioniAttributo2(Id, DataPartizione, 'Risultato')) as Risultato
		,CONVERT(VARCHAR(255), dbo.GetPrestazioniAttributo2(Id, DataPartizione, 'ValoriRiferimento')) AS ValoriRiferimento

		,dbo.GetPrestazioniAttributo2Integer(Id, DataPartizione, 'SezionePosizione') as SezionePosizione
		,dbo.GetPrestazioniAttributo2Integer(Id, DataPartizione, 'PrestazionePosizione') as PrestazionePosizione

		,CONVERT(VARCHAR (2048),dbo.GetPrestazioniAttributo2(Id, DataPartizione, 'Commenti')) as Commenti

		,dbo.GetPrestazioniAttributo2Decimal(Id, DataPartizione, 'Quantita') as Quantita
		,CONVERT(VARCHAR (255),dbo.GetPrestazioniAttributo2(Id, DataPartizione, 'UnitaDiMisuraDescrizione')) as UnitaDiMisura

		,CONVERT(VARCHAR(255),dbo.GetPrestazioniAttributo2(Id, DataPartizione, 'RangeDiNormalitaValoreMinimo')) as RangeValoreMinimo
		,CONVERT(VARCHAR(255),dbo.GetPrestazioniAttributo2(Id, DataPartizione, 'RangeDiNormalitaValoreMassimo')) as RangeValoreMassimo
		,CONVERT(VARCHAR(255),dbo.GetPrestazioniAttributo2(Id, DataPartizione, 'RangeDiNormalitaValoreMinimoUDM')) as RangeValoreMinimoUnitaDiMisura
		,CONVERT(VARCHAR(255),dbo.GetPrestazioniAttributo2(Id, DataPartizione, 'RangeDiNormalitaValoreMassimoUDM')) as RangeValoreMassimoUnitaDiMisura

		,dbo.[GetPrestazioniAttributi2Xml](ID, DataPartizione) Attributi

	FROM [dbo].[PrestazioniBase]
