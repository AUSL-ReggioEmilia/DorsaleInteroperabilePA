
CREATE VIEW [DataAccess].[Allegati] AS
/*
	CREATA DA SANDRO 2015-05-22: 
		Nuova vista ad uso esclusivo accesso ESTERNO
		Utilizzo nuova vista store.Allegati
*/
SELECT [ID]
      ,[DataPartizione]
      ,[IdRefertiBase]
      ,[IdEsterno]
      ,[DataInserimento],[DataModifica]
      ,[DataFile],[MimeType]
      ,[MimeData],[NomeFile]
      ,[Descrizione],[Posizione]
      ,[StatoCodice],[StatoDescrizione]

	  -- Converto in nVARCHAR perche XML non permette le query distribuite
	  , CONVERT(NVARCHAR(MAX), Attributi) AS Attributi

  FROM [store].[Allegati] WITH(NOLOCK)

