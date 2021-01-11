
-- =============================================
-- Author:      ETTORE
-- Create date: 2019-03-25
-- Description: Riempie la tabella SinotticoUltimoMese con i dati aggregati per sistema 
--				dalla @dataDa = GETDATE()-33 a @dataA = GETDATE()
-- =============================================
CREATE PROCEDURE [dbo].[Maintenance_BuildSinotticoUltimoMese]
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @RowCount INTEGER = 0

	DECLARE @dataDa DATETIME = DATEADD(day, -33, GETDATE()) --indietro di 33 giorni
	DECLARE @dataA DATETIME= GETDATE()

	DECLARE @TempSinottico AS TABLE 
	(
		Id uniqueidentifier NOT NULL,
		IdSistemaErogante uniqueidentifier NOT NULL,
		IdSistemaRichiedente uniqueidentifier NOT NULL,
		Stato varchar(100) NOT NULL,
		Giorno date NOT NULL,
		NumeroOrdini int NULL
	)
		
	INSERT INTO @TempSinottico
	(	 [Id]
		,[IdSistemaErogante]
		,[IdSistemaRichiedente]
		,[Stato]
		,[Giorno]
		,[NumeroOrdini]
	)
	SELECT 
		NEWID() as Id, 
		IdSistemaErogante, 
		IDSistemaRichiedente, 
		Stato, 
		Giorno, 
		SUM(NumeroOrdini) as NumeroOrdini 
	FROM
	(
		SELECT 
			ORR.IdSistemaErogante, 
			T.IDSistemaRichiedente, 
			dbo.GetStatoSenzaSottostato2(T.ID, T.StatoOrderEntry) as Stato, 
			CAST(T.DataRichiesta AS DATE) as Giorno, 
			COUNT(*) as NumeroOrdini
		FROM 
			OrdiniTestate T (NOLOCK) 
		LEFT JOIN 
			OrdiniRigheRichieste (NOLOCK) ORR on ORR.IDOrdineTestata = T.ID
		WHERE 
			ORR.IDSistemaErogante IS NOT NULL 
			AND T.DataRichiesta BETWEEN @dataDa AND @dataA
			AND ORR.IdSistemaErogante <> '00000000-0000-0000-0000-000000000000' 

		GROUP BY 
			T.IDSistemaRichiedente,
			ORR.IdSistemaErogante,
			dbo.GetStatoSenzaSottostato2(T.ID, T.StatoOrderEntry),
			CAST(T.DataRichiesta AS DATE)  

		UNION ALL

		SELECT 
			Sistemi.ID, 
			T.IDSistemaRichiedente, 
			dbo.GetStatoSenzaSottostato2(T.ID, T.StatoOrderEntry) as Stato, 
			CAST(T.DataRichiesta AS DATE) AS Giorno, 
			COUNT(*) as NumeroOrdini
		FROM 
			OrdiniTestate T (NOLOCK) 
		LEFT JOIN 
			OrdiniRigheRichieste (NOLOCK) ORR on ORR.IDOrdineTestata = T.ID
		LEFT JOIN 
			PrestazioniProfili (NOLOCK) on PrestazioniProfili.IDPadre = ORR.IDPrestazione
		LEFT JOIN 
			Prestazioni (NOLOCK) on Prestazioni.ID = PrestazioniProfili.IDFiglio
		LEFT JOIN 
			Sistemi (NOLOCK) on Sistemi.ID = Prestazioni.IdSistemaErogante
		                          
		WHERE 
			ORR.IDSistemaErogante IS NOT NULL
			AND T.DataRichiesta BETWEEN @dataDa AND @dataA
			AND ORR.IdSistemaErogante = '00000000-0000-0000-0000-000000000000'
			AND Sistemi.ID <> '00000000-0000-0000-0000-000000000000'  
		 
		GROUP BY 
			T.IDSistemaRichiedente, 
			Sistemi.ID, 
			dbo.GetStatoSenzaSottostato2(T.ID, T.StatoOrderEntry), 
			CAST(T.DataRichiesta AS DATE) 

	) O
	
	GROUP BY IDSistemaRichiedente, IdSistemaErogante, Stato, Giorno

	--
	-- DELETE ED INSERIMENTO
	--
	--DELETE SinotticoUltimoMese 
	--WHERE Giorno BETWEEN @dataDa AND @dataA	
	--SELECT @RowCount = @@ROWCOUNT
	--PRINT 'RIGHECANCELLATE: ' + CAST(@RowCount AS VARCHAR(10))

	TRUNCATE TABLE SinotticoUltimoMese 
		
	INSERT INTO SinotticoUltimoMese
	(	 [Id]
		,[IdSistemaErogante]
		,[IdSistemaRichiedente]
		,[Stato]
		,[Giorno]
		,[NumeroOrdini]
	)
	SELECT
		 [Id]
		,[IdSistemaErogante]
		,[IdSistemaRichiedente]
		,[Stato]
		,[Giorno]
		,[NumeroOrdini]
	FROM @TempSinottico

	SELECT @RowCount = @@ROWCOUNT
	PRINT 'RIGHEINSERITE: ' + CAST(@RowCount AS VARCHAR(10))
	
END