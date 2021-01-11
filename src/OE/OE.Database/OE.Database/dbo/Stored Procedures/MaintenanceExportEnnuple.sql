
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-24
-- Modify date: 2014-03-27 Aggiunto campo Preferiti a GruppiPrestazioni
--						   Aggiunto campo CancellazionePostInoltro a Sistema
-- Description:	Esporta le configurazioni delle ennuple
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceExportEnnuple]
	@IDEnnupla UNIQUEIDENTIFIER
	,@Utenti BIT = 0
	,@Prestazioni BIT = 0
AS
BEGIN

	SET NOCOUNT ON
  
		SELECT ID, IDGruppoUtenti, IDGruppoPrestazioni, Descrizione, OrarioInizio, OrarioFine
			, Lunedi, Martedi, Mercoledi, Giovedi, Venerdi, Sabato, Domenica
			, IDUnitaOperativa, IDSistemaRichiedente, CodiceRegime, CodicePriorita, [Not], IDStato
			, (SELECT Codice FROM [UnitaOperative] WHERE ID = IDUnitaOperativa) AS UnitaOperativaCodice
			, (SELECT CodiceAzienda FROM [UnitaOperative] WHERE ID = IDUnitaOperativa) AS UnitaOperativaAzienda
			, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaRichiedente) AS SistemaRichiedenteCodice
			, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaRichiedente) AS SistemaRichiedenteAzienda

		--[SistemiRichiedenti]
		, CONVERT(xml, (
			SELECT ID, Codice, Descrizione, Erogante, Richiedente, CodiceAzienda, Attivo, CancellazionePostInoltro
				FROM [dbo].[Sistemi] AS SistemaRichiedente
				WHERE [ID] = Ennupla.IDSistemaRichiedente
				ORDER BY Codice
				FOR XML AUTO
			)) AS SistemiRichiedenti

		--[UnitaOperative]
		, CONVERT(xml, (
			SELECT ID, Codice, Descrizione, CodiceAzienda, Attivo
				FROM [dbo].[UnitaOperative] AS UnitaOperativa
				WHERE [ID] = Ennupla.IDUnitaOperativa
				ORDER BY Codice
				FOR XML AUTO
			)) AS UnitaOperative


		--[GruppiUtenti]
		, CONVERT(xml, (
			SELECT ID, Descrizione
			
			--[Utenti]
			, CASE WHEN @Utenti = 1 THEN
				CONVERT(xml, (
						SELECT ID, Utente, Descrizione, Attivo, Delega
							, GruppoUtenti.ID AS IDGruppoUtenti
						FROM [dbo].[Utenti] AS Utente
						WHERE [ID] IN (
										SELECT IDUtente
										FROM [dbo].[UtentiGruppiUtenti] UGU
										WHERE UGU.IDGruppoUtenti = GruppoUtenti.ID
										)
						ORDER BY Utente
						FOR XML AUTO
					))
					ELSE NULL END AS Utenti
						
				FROM [dbo].[GruppiUtenti] AS GruppoUtenti
				WHERE [ID] = Ennupla.IDGruppoUtenti
				ORDER BY Descrizione
				FOR XML AUTO
			)) AS GruppiUtenti

		--[GruppiPrestazioni]
		, CONVERT(xml, (
			SELECT ID, Descrizione, Preferiti
				
			--[Prestazioni]
			, CASE WHEN @Prestazioni = 1 THEN
					CONVERT(xml, (
						SELECT ID, Codice, Descrizione, Tipo, Provenienza, IDSistemaErogante, Attivo, CodiceSinonimo
								, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteCodice
								, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteAzienda
						FROM [dbo].[Prestazioni] AS Prestazione
						WHERE [ID] IN (
										SELECT IDPrestazione
										FROM [dbo].[PrestazioniGruppiPrestazioni] PGP
										WHERE PGP.IDGruppoPrestazioni = GruppoPrestazioni.ID
										)
						ORDER BY Codice
						FOR XML AUTO
						))
					ELSE NULL END AS Prestazioni
			
				FROM [dbo].[GruppiPrestazioni] AS GruppoPrestazioni
				WHERE [ID] = Ennupla.IDGruppoPrestazioni
				ORDER BY Descrizione
				FOR XML AUTO
			)) AS GruppiPrestazioni
			
	FROM [dbo].[Ennuple] AS Ennupla
		
	WHERE Ennupla.ID = @IDEnnupla
		OR @IDEnnupla IS NULL
		
	ORDER BY Descrizione

	FOR XML AUTO, ROOT('Ennuple')

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MaintenanceExportEnnuple] TO [ExecuteImportExport]
    AS [dbo];

