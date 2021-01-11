
CREATE PROCEDURE [dbo].[Maintenance_SyncOrganigramma]
AS
BEGIN
	SET NOCOUNT ON
	--
	-- Inserisce i nuovi sistemi nel SAC
	--
	INSERT INTO [SacOrganigramma].[Sistemi] ([ID]
		  ,[Codice]
		  ,[Azienda]
		  ,[Descrizione]
		  ,[Richiedente]
		  ,[Erogante]
		  ,[Attivo])
	SELECT [ID]
		  ,[Codice]
		  ,[CodiceAzienda]
		  ,[Descrizione]
		  ,[Richiedente]
		  ,[Erogante]
		  ,[Attivo]
	FROM [dbo].[Sistemi]
		WHERE ID <> '00000000-0000-0000-0000-000000000000'
			AND NOT EXISTS (SELECT * FROM [SacOrganigramma].[Sistemi] s
								WHERE s.ID=Sistemi.ID
									OR (s.[Codice] = Sistemi.[Codice]
									AND s.[Azienda] = Sistemi.[CodiceAzienda])
							)
	--
	-- Inserisce i nuovi sistemi in OE
	--
	INSERT INTO [dbo].[Sistemi] ([ID]
		  ,[Codice]
		  ,[CodiceAzienda]
		  ,[Descrizione]
		  ,[Richiedente]
		  ,[Erogante]
		  ,[Attivo])
	SELECT [ID]
		  ,[Codice]
		  ,[Azienda]
		  ,[Descrizione]
		  ,[Richiedente]
		  ,[Erogante]
		  ,[Attivo]
	FROM [SacOrganigramma].[Sistemi]
		WHERE ID <> '00000000-0000-0000-0000-000000000000'
			AND NOT EXISTS (SELECT * FROM [dbo].[Sistemi] s
								WHERE s.ID=Sistemi.ID
									OR (s.[Codice] = Sistemi.[Codice]
									AND s.[CodiceAzienda] = Sistemi.[Azienda])
							)
	--
	-- Aggiorna i nuovi sistemi IN OE
	--
	UPDATE [dbo].[Sistemi] 
	SET    [Codice] = sac.[Codice]
		  ,[CodiceAzienda] = sac.[Azienda]
		  ,[Descrizione] = sac.[Descrizione]
		  ,[Richiedente] = sac.[Richiedente]
		  ,[Erogante] = sac.[Erogante]
		  --,[Attivo] = sac.[Attivo]

	FROM [dbo].[Sistemi] s
		INNER JOIN [SacOrganigramma].[Sistemi] sac
		ON s.[ID] = sac.[ID]
			AND s.[Codice] = sac.[Codice]
			AND s.[CodiceAzienda] = sac.[Azienda]
			AND sac.ID != '00000000-0000-0000-0000-000000000000'

	WHERE ISNULL(s.[Descrizione], '') <> ISNULL(sac.[Descrizione], '')
		OR s.[Richiedente] <> sac.[Richiedente]
		OR s.[Erogante] <> sac.[Erogante]
		--OR s.[Attivo] <> sac.[Attivo]

	--
	-- Inserisce le nuove UO in SAC
	--
	INSERT INTO [SacOrganigramma].[UnitaOperative] ([ID]
		  ,[Codice]
		  ,[Azienda]
		  ,[Descrizione]
		  ,[Attivo])
	SELECT [ID]
		  ,[Codice]
		  ,[CodiceAzienda]
		  ,[Descrizione]
		  ,[Attivo]
	FROM [dbo].[UnitaOperative]
		WHERE ID != '00000000-0000-0000-0000-000000000000'
		AND NOT EXISTS (SELECT * FROM [SacOrganigramma].[UnitaOperative] u
							WHERE u.ID=UnitaOperative.ID
								OR ( u.[Codice] = UnitaOperative.[Codice]
									AND u.[Azienda] = UnitaOperative.[CodiceAzienda])
						)
	--
	-- Inserisce le nuove UO in OE
	--
	INSERT INTO [dbo].[UnitaOperative] ([ID]
		  ,[Codice]
		  ,[CodiceAzienda]
		  ,[Descrizione]
		  ,[Attivo])
	SELECT [ID]
		  ,[Codice]
		  ,[Azienda]
		  ,[Descrizione]
		  ,[Attivo]
	FROM [SacOrganigramma].[UnitaOperative]
		WHERE ID != '00000000-0000-0000-0000-000000000000'
		AND NOT EXISTS (SELECT * FROM [dbo].[UnitaOperative] u
							WHERE u.ID=UnitaOperative.ID
								OR ( u.[Codice] = UnitaOperative.[Codice]
									AND u.[CodiceAzienda] = UnitaOperative.[Azienda])
						)
	--
	-- Aggiorna le nuove UO
	--
	UPDATE [dbo].[UnitaOperative] 
	SET    [Codice] = sac.[Codice]
		  ,[CodiceAzienda] = sac.[Azienda]
		  ,[Descrizione] = sac.[Descrizione]
		  --,[Attivo] = sac.[Attivo]

	FROM [dbo].[UnitaOperative] u
		INNER JOIN [SacOrganigramma].[UnitaOperative] sac
			ON u.ID=sac.ID
				AND u.[Codice] = sac.[Codice]
				AND u.[CodiceAzienda] = sac.[Azienda]
				AND sac.ID != '00000000-0000-0000-0000-000000000000'

	WHERE ISNULL(u.[Descrizione], '') <> ISNULL(sac.[Descrizione], '')
		--OR u.[Attivo] <> sac.[Attivo]

END