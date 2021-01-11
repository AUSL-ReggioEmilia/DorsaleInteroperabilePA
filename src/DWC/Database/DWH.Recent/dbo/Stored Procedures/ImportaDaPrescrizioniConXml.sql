CREATE PROCEDURE [dbo].[ImportaDaPrescrizioniConXml]
AS
BEGIN

	SET NOCOUNT ON;
	------------------------------------------------------
	-- PRESCRIZIONI
	------------------------------------------------------

	INSERT INTO [dbo].[PrescrizioniBase]
			   ([Id]
			   ,[DataPartizione]
			   ,[IdEsterno]
			   ,[IdPaziente]
			   ,[DataInserimento]
			   ,[DataModifica]
			   ,[DataModificaEsterno]
			   ,[StatoCodice]
			   ,[TipoPrescrizione]
			   ,[DataPrescrizione]
			   ,[NumeroPrescrizione]
			   ,[MedicoPrescrittoreCodiceFiscale]
			   ,[QuesitoDiagnostico])
	SELECT [Id]
		  ,[DataPartizione]
		  ,[IdEsterno]
		  ,[IdPaziente]
		  ,[DataInserimento]
		  ,[DataModifica]
		  ,[DataModificaEsterno]
		  ,[StatoCodice]
		  ,[TipoPrescrizione]
		  ,[DataPrescrizione]
		  ,[NumeroPrescrizione]
		  ,[MedicoPrescrittoreCodiceFiscale]
		  ,[QuesitoDiagnostico]
	  FROM [dbo].[Prescrizioni_old]

	------------------------------------------------------
	-- PRESCRIZIONI ATTRIBUTI DOPPI
	------------------------------------------------------

	;WITH Attributi AS
	(
	SELECT [Id]
		  ,[DataPartizione]
		  ,Tab.Col.value('@Nome', 'varchar(64)') AS Nome
		  ,Tab.Col.value('@Valore', 'varchar(8000)') AS Valore
	FROM [dbo].[Prescrizioni_old]
		CROSS APPLY [Attributi].nodes('/Attributi/Attributo') Tab(Col)
	)

	INSERT INTO [dbo].[PrescrizioniAttributi]
			   ([IdPrescrizioniBase]
			   ,[DataPartizione]
			   ,[Nome]
			   ,[Valore])
	SELECT [Id]
		  ,[DataPartizione]
		  ,[Nome]
		  ,CONVERT(VARCHAR(8000), 
				SUBSTRING((SELECT '; ' + [Valore] AS 'data()' FROM Attributi a
						WHERE a.[Id]=Attributi.[Id]
							AND a.[DataPartizione]=Attributi.[DataPartizione]
							AND a.[Nome]=Attributi.[Nome]
							AND NOT NULLIF(a.[Valore], '') IS NULL
						FOR XML PATH('')), 3, 8000)
				) [Valore]
	FROM Attributi
	GROUP BY [Id]
		  ,[DataPartizione]
		  ,[Nome]
	HAVING COUNT(*) > 1
	ORDER BY [Id]
		  ,[DataPartizione]

	------------------------------------------------------
	-- PRESCRIZIONI ATTRIBUTI DOPPI
	------------------------------------------------------

	;WITH Attributi AS
	(
	SELECT [Id]
		  ,[DataPartizione]
		  ,Tab.Col.value('@Nome', 'varchar(64)') AS Nome
		  ,Tab.Col.value('@Valore', 'varchar(8000)') AS Valore
	FROM [dbo].[Prescrizioni_old]
		CROSS APPLY [Attributi].nodes('/Attributi/Attributo') Tab(Col)
	)

	INSERT INTO [dbo].[PrescrizioniAttributi]
			   ([IdPrescrizioniBase]
			   ,[DataPartizione]
			   ,[Nome]
			   ,[Valore])
	SELECT [Id]
		  ,[DataPartizione]
		  ,[Nome]
		  , MIN([Valore]) AS [Valore]
	FROM Attributi
	GROUP BY [Id]
		  ,[DataPartizione]
		  ,[Nome]
	HAVING COUNT(*) = 1
	ORDER BY [Id]
		  ,[DataPartizione]



	------------------------------------------------------
	-- PRESCRIZIONI ALLEGATI
	------------------------------------------------------

	INSERT INTO [dbo].[PrescrizioniAllegatiBase]
			   ([ID]
			  ,[DataPartizione]
			  ,[IdPrescrizioniBase]
			  ,[IdEsterno]
			  ,[DataInserimento]
			  ,[DataModifica]
			  ,[TipoContenuto]
			  ,[ContenutoCompresso])
	SELECT [ID]
		  ,[DataPartizione]
		  ,[IdPrescrizioni]
		  ,[IdEsterno]
		  ,[DataInserimento]
		  ,[DataModifica]
		  ,[TipoContenuto]
		  ,[ContenutoCompresso]
	  FROM [dbo].[PrescrizioniAllegati_old]

	------------------------------------------------------
	-- PRESCRIZIONI ALLEGATI ATTRIBUTI
	------------------------------------------------------

	;WITH Attributi AS
	(
	SELECT [Id]
		  ,[DataPartizione]
		  ,Tab.Col.value('@Nome', 'varchar(64)') AS Nome
		  ,Tab.Col.value('@Valore', 'varchar(8000)') AS Valore
	FROM [dbo].[PrescrizioniAllegati_old]
		CROSS APPLY [Attributi].nodes('/Attributi/Attributo') Tab(Col)
	)

	INSERT INTO [dbo].[PrescrizioniAllegatiAttributi]
			   ([IdPrescrizioniAllegatiBase]
			   ,[DataPartizione]
			   ,[Nome]
			   ,[Valore])
	SELECT [Id]
		  ,[DataPartizione]
		  ,[Nome]
		  ,[Valore]
	FROM Attributi
	ORDER BY [Id] ,[DataPartizione]

	------------------------------------------------------
	------------------------------------------------------
END