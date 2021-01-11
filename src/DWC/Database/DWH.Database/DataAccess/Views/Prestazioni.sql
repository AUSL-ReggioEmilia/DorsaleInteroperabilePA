
CREATE VIEW [DataAccess].[Prestazioni] AS
/*
	CREATA DA SANDRO 2015-05-22: 
		Nuova vista ad uso esclusivo accesso ESTERNO
		Utilizzo nuova vista store.Prestazioni

	MODIFICATE 2016-10-07 SANDRO: Converto in nVARCHAR perche XML non permette le query distribuite

*/
	SELECT [ID]
		  ,[DataPartizione]
		  ,[IdRefertiBase]
		  ,[IdEsterno]
		  ,[DataInserimento],[DataModifica]
		  ,[DataErogazione]
		  ,[PrestazioneCodice],[PrestazioneDescrizione]
		  ,[SezioneCodice],[SezioneDescrizione]
		  ,[GravitaCodice],[GravitaDescrizione]
		  ,[Risultato],[ValoriRiferimento]
		  ,[SezionePosizione],[PrestazionePosizione]
		  ,[Commenti]

		  ,[Quantita],[UnitaDiMisura]
		  ,[RangeValoreMinimo],[RangeValoreMassimo]
		  ,[RangeValoreMinimoUnitaDiMisura],[RangeValoreMassimoUnitaDiMisura]

		-- Converto in nVARCHAR perche XML non permette le query distribuite
		  ,CONVERT(NVARCHAR(MAX), Attributi) AS Attributi
	  FROM [store].[Prestazioni] WITH(NOLOCK)

