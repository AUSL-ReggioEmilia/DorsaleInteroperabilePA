
CREATE PROCEDURE [dbo].[MaintenanceStorico_TabelleDiBase]
AS
BEGIN
--MODIFICHE:
-- 2020-04-22 Sandro: Primo rilascio 

	SET NOCOUNT ON

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Inizio dati di base da storicizzare'
	--
	-- [OrdiniErogatiStati]
	--
	DELETE [dbo].[OrdiniErogatiStati_Storico]
	FROM [dbo].[OrdiniErogatiStati] s
		INNER JOIN [dbo].[OrdiniErogatiStati_Storico] d
			ON s.Codice = d.Codice
	WHERE CHECKSUM(s.Descrizione, s.Note, s.Ordinamento)
		<> CHECKSUM(d.Descrizione, d.Note, d.Ordinamento)

	INSERT INTO [dbo].[OrdiniErogatiStati_Storico]
	SELECT *
	FROM [dbo].[OrdiniErogatiStati]
	WHERE NOT Codice IN (SELECT Codice FROM [dbo].[OrdiniErogatiStati_Storico])

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Inseriti ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [OrdiniErogatiStati]'

	--
	-- [OrdiniStati]
	--
	DELETE [dbo].[OrdiniStati_Storico]
	FROM [dbo].[OrdiniStati] s
		INNER JOIN [dbo].[OrdiniStati_Storico] d
			ON s.Codice = d.Codice
	WHERE CHECKSUM(s.Descrizione, s.Note, s.Ordinamento)
		<> CHECKSUM(d.Descrizione, d.Note, d.Ordinamento)

	INSERT INTO [dbo].[OrdiniStati_Storico]
	SELECT *
	FROM [dbo].[OrdiniStati]
	WHERE NOT Codice IN (SELECT Codice FROM [dbo].[OrdiniStati_Storico])

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Inseriti ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [OrdiniStati]'

	--
	-- [Sistemi_Storico]
	--
	DELETE [dbo].[Sistemi_Storico]
	FROM [dbo].[Sistemi] s
		INNER JOIN [dbo].[Sistemi_Storico] d
			ON s.Id = d.Id
	WHERE CHECKSUM(s.Codice, s.CodiceAzienda, s.Descrizione, s.Richiedente, s.Erogante, s.Attivo, s.CancellazionePostInoltro, s.CancellazionePostInCarico)
		<> CHECKSUM(d.Codice, d.CodiceAzienda, d.Descrizione, d.Richiedente, d.Erogante, d.Attivo, d.CancellazionePostInoltro, d.CancellazionePostInCarico)

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Rimossi ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [Sistemi]'

	INSERT INTO [dbo].[Sistemi_Storico]
	SELECT *
	FROM [dbo].[Sistemi]
	WHERE NOT Id IN (SELECT Id FROM [dbo].[Sistemi_Storico])
			AND (
				   EXISTS(SELECT * FROM [MessaggiRichieste_Storico] WHERE [IDSistemaRichiedente] = [Sistemi].[ID])
				OR EXISTS(SELECT * FROM [MessaggiStati_Storico] WHERE [IDSistemaRichiedente] = [Sistemi].[ID])
				OR EXISTS(SELECT * FROM [OrdiniErogatiTestate_Storico] WHERE [IDSistemaRichiedente] = [Sistemi].[ID])
				OR EXISTS(SELECT * FROM [OrdiniErogatiTestate_Storico] WHERE [IDSistemaErogante] = [Sistemi].[ID])
				OR EXISTS(SELECT * FROM [OrdiniTestate_Storico] WHERE [IDSistemaRichiedente] = [Sistemi].[ID])
				OR EXISTS(SELECT * FROM [OrdiniRigheRichieste_Storico] WHERE [IDSistemaErogante] = [Sistemi].[ID])
				OR EXISTS(SELECT * FROM [Prestazioni_Storico] WHERE [IDSistemaErogante] = [Sistemi].[ID])
				OR EXISTS(SELECT * FROM [OrdiniErogatiTestate_Storico] WHERE [IDSistemaRichiedente] = [Sistemi].[ID])
				OR EXISTS(SELECT * FROM [OrdiniErogatiTestate_Storico] WHERE [IDSistemaErogante] = [Sistemi].[ID])
				)

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Inseriti ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [Sistemi]'

	--
	-- [UnitaOperative_Storico]
	--
	DELETE [dbo].[UnitaOperative_Storico]
	FROM [dbo].[UnitaOperative] s
		INNER JOIN [dbo].[UnitaOperative_Storico] d
			ON s.Id = d.Id
	WHERE CHECKSUM(s.Codice, s.CodiceAzienda, s.Descrizione, s.Attivo)
		<> CHECKSUM(d.Codice, d.CodiceAzienda, d.Descrizione, d.Attivo)
	
	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Rimossi ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [UnitaOperative]'

	INSERT INTO [dbo].[UnitaOperative_Storico]
	SELECT *
	FROM [dbo].[UnitaOperative]
	WHERE NOT Id IN (SELECT Id FROM [dbo].[UnitaOperative_Storico])
			AND EXISTS(SELECT * FROM [OrdiniTestate_Storico] WHERE [IDUnitaOperativaRichiedente] = [UnitaOperative].[ID])

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Inseriti ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [UnitaOperative]'

	--
	-- [Prestazioni_Storico]
	--
	DELETE FROM [dbo].[Prestazioni_Storico]
	FROM [dbo].[Prestazioni] s
		INNER JOIN [dbo].[Prestazioni_Storico] d
			ON s.Id = d.Id
	WHERE s.TS <> d.TS

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Rimossi ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [Prestazioni]'

	INSERT INTO [dbo].[Prestazioni_Storico]
	SELECT *
	FROM [dbo].[Prestazioni]
	WHERE NOT Id IN (SELECT Id FROM [dbo].[Prestazioni_Storico])
			AND EXISTS(SELECT * FROM [dbo].[OrdiniRigheRichieste_Storico] WHERE [IDPrestazione] = [Prestazioni].[ID])

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Inseriti ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [Prestazioni]'

	--
	-- [dbo].[PrestazioniProfili_Storico]
	--
	DELETE FROM [dbo].[PrestazioniProfili_Storico]
	FROM [dbo].[PrestazioniProfili] s
		INNER JOIN [dbo].[PrestazioniProfili_Storico] d
			ON s.Id = d.Id
	WHERE CHECKSUM(s.IDFiglio, s.IDPadre)
		<> CHECKSUM(d.IDFiglio, d.IDPadre)

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Rimossi ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [PrestazioniProfili]'

	INSERT INTO [dbo].[PrestazioniProfili_Storico]
	SELECT *
	FROM [dbo].[PrestazioniProfili]
	WHERE NOT Id IN (SELECT Id FROM [dbo].[PrestazioniProfili_Storico])
			AND (
					EXISTS(SELECT * FROM [dbo].[Prestazioni_Storico] WHERE [ID] = [PrestazioniProfili].[IDPadre])
				OR EXISTS(SELECT * FROM [dbo].[Prestazioni_Storico] WHERE [ID] = [PrestazioniProfili].[IDFiglio])
				)

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Inseriti ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [PrestazioniProfili]'

	--
	-- [Tickets_Storico]
	--

	DELETE [dbo].[Tickets_Storico]
	FROM [dbo].[Tickets] s
		INNER JOIN [dbo].[Tickets_Storico] d
			ON s.Id = d.Id
	WHERE s.DataLettura <> d.DataLettura
	
	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Rimossi ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [Tickets]'

	INSERT INTO [dbo].[Tickets_Storico]
	SELECT *
	FROM [dbo].[Tickets]
	WHERE NOT Id IN (SELECT Id FROM [dbo].[Tickets_Storico])
			AND (
				   EXISTS(SELECT * FROM [OrdiniErogatiTestate_Storico] WHERE [IDTicketInserimento] = [Tickets].[ID])
				OR EXISTS(SELECT * FROM [OrdiniErogatiTestate_Storico] WHERE [IDTicketModifica] = [Tickets].[ID])

				OR EXISTS(SELECT * FROM [OrdiniTestate_Storico] WHERE [IDTicketInserimento] = [Tickets].[ID])
				OR EXISTS(SELECT * FROM [OrdiniTestate_Storico] WHERE [IDTicketModifica] = [Tickets].[ID])

				OR EXISTS(SELECT * FROM [MessaggiRichieste_Storico] WHERE [IDTicketInserimento] = [Tickets].[ID])
				OR EXISTS(SELECT * FROM [MessaggiRichieste_Storico] WHERE [IDTicketModifica] = [Tickets].[ID])

				OR EXISTS(SELECT * FROM [MessaggiStati_Storico] WHERE [IDTicketInserimento] = [Tickets].[ID])
				OR EXISTS(SELECT * FROM [MessaggiStati_Storico] WHERE [IDTicketModifica] = [Tickets].[ID])

				OR EXISTS(SELECT * FROM [OrdiniErogatiVersioni_Storico] WHERE [IDTicketInserimento] = [Tickets].[ID])
				OR EXISTS(SELECT * FROM [OrdiniVersioni_Storico] WHERE [IDTicketInserimento] = [Tickets].[ID])
			)

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Inseriti ' + CONVERT(varchar(10), @@ROWCOUNT) + ' [Tickets]'

	PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Fine storicizzazione dati di base'

END