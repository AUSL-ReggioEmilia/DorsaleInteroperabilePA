
CREATE PROCEDURE [dbo].[MntSyncOrganigramma]
AS
BEGIN
-- 2020-04-15 SAndro: Aggiunto Sync delle aziende
--
--
	DECLARE @NumRow INTEGER = 0
	
	SET NOCOUNT ON
	--
	-- Inserisce i nuovi sistemi nel SAC leggendoli dal DWH: DWH -> SAC
	-- Se interfaccia DWH non inserisce questo pezzo non servirebbe , ma si potrebbe fare insert via script quindi va fatto!
	--
	INSERT INTO [dbo].[SAC_Aziende] ([Codice], [Descrizione])
	SELECT DWH_S.AziendaErogante AS [Codice]
		  ,'Importato da DWH' AS [Descrizione]
	FROM [dbo].[SistemiEroganti] AS DWH_S
		WHERE ID <> '00000000-0000-0000-0000-000000000000'
			AND NOT EXISTS (SELECT * FROM [dbo].[SAC_Aziende] AS SAC_S
								WHERE SAC_S.[Codice] = DWH_S.[AziendaErogante]
							)

	SELECT @NumRow = @@ROWCOUNT
	PRINT 'DWH -> SAC - Inserimento azienda: ' + CAST(@NumRow  AS VARCHAR(10))

	INSERT INTO SAC_Sistemi ([ID]
		  ,[Codice]
		  ,[Azienda]
		  ,[Descrizione]
		  ,[Richiedente]
		  ,[Erogante]
		  ,[Attivo])
	SELECT [ID]
		  ,DWH_S.SistemaErogante AS [Codice]
		  ,DWH_S.AziendaErogante AS [Azienda]
		  ,DWH_S.[Descrizione]
		  ,CAST(0 AS BIT) AS [Richiedente]
		  ,CAST(1 AS BIT) AS [Erogante]
		  ,CAST(1 AS BIT) AS [Attivo]
	FROM [dbo].[SistemiEroganti] AS DWH_S
		WHERE ID <> '00000000-0000-0000-0000-000000000000'
			AND NOT EXISTS (SELECT * FROM SAC_Sistemi AS SAC_S
								WHERE SAC_S.[Codice] = DWH_S.[SistemaErogante]
									AND SAC_S.[Azienda] = DWH_S.[AziendaErogante]
							)

	SELECT @NumRow = @@ROWCOUNT
	PRINT 'DWH -> SAC - Inserimento sistemi: ' + CAST(@NumRow  AS VARCHAR(10))

	--
	-- SAC -> DWH
	-- Inserisce i nuovi sistemi in DWH leggendoli dal SAC: 
	-- Inserisce molti sistemi che non sono eroganti di referti...
	-- Li si potrebe inserire lo stesso e poi si lascia i flag TipoReferti, TipoEventi a 0.
	-- Nelle SP dove si leggono i SistemiEroganti si leggono solo quelli che hanno almeno uno dei due flag a 1. Quelli con Tiporeferti=1 vengono usati negli abbonamenti.
	--
	INSERT INTO [dbo].[SistemiEroganti] (
		[ID]
		,[SistemaErogante]
		,[AziendaErogante]
		,[Descrizione]
		, [LoginToSac]
		)
	SELECT SAC_S.[ID]
		  ,SAC_S.[Codice] AS SistemaErogante
		  ,SAC_S.[Azienda] AS AziendaErogante
		  ,SAC_S.[Descrizione] 
		  ,'SAC_DWC' AS LoginToSac 
	FROM SAC_Sistemi AS SAC_S
		WHERE ID <> '00000000-0000-0000-0000-000000000000'
			AND SAC_S.Erogante = 1 --IMPORTANTE: solo gli eroganti (potrebbe essere eroganti NON di referti...)
			AND NOT EXISTS (SELECT * FROM [dbo].[SistemiERoganti] DWH_S
								WHERE (
									DWH_S.[SistemaErogante] = SAC_S.[Codice]
									AND DWH_S.[AziendaErogante] = SAC_S.[Azienda]
									)
							)
	SELECT @NumRow = @@ROWCOUNT
	PRINT 'SAC -> DWH - Inserimento sistemi: ' + CAST(@NumRow  AS VARCHAR(10))
			
	--
	-- Aggiorna i nuovi sistemi IN DWH leggendoli dal SAC
	--
	UPDATE DWH_S
	SET DWH_S.[Descrizione] = SAC_S.[Descrizione]
	FROM 
		[dbo].[SistemiEroganti] AS DWH_S
		INNER JOIN SAC_Sistemi AS SAC_S
		ON DWH_S.[SistemaErogante] = SAC_S.[Codice]
			AND DWH_S.[AziendaErogante] = SAC_S.[Azienda]
			AND (SAC_S.ID <> '00000000-0000-0000-0000-000000000000')
	WHERE 
		SAC_S.[Erogante] = 1 --IMPORTANTE: solo gli eroganti (potrebbe essere eroganti NON di referti...)
		AND (
			ISNULL(DWH_S.[Descrizione], '') <> ISNULL(SAC_S.[Descrizione], '')
			)

	SELECT @NumRow = @@ROWCOUNT
	PRINT 'SAC -> DWH - Aggiornamento sistemi: ' + CAST(@NumRow  AS VARCHAR(10))


END