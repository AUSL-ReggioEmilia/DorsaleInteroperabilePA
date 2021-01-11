
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-24
-- Description:	Esporta le configurazioni delle prestazioni
--				 e dati accessori di un gruppo di prestazioni
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceExportUtentiPerGruppo]
	@IDGruppoUtenti UNIQUEIDENTIFIER
AS
BEGIN

	SET NOCOUNT ON
  
	SELECT ID, Descrizione
		
		--[Ennuple]
		, CONVERT(xml, (	
				SELECT Gruppo.ID AS IDGruppo,
					ID, IDGruppoUtenti, IDGruppoPrestazioni, Descrizione, OrarioInizio, OrarioFine
					, Lunedi, Martedi, Mercoledi, Giovedi, Venerdi, Sabato, Domenica
					, IDUnitaOperativa, IDSistemaRichiedente, CodiceRegime, CodicePriorita, [Not], IDStato
					, (SELECT Codice FROM [UnitaOperative] WHERE ID = IDUnitaOperativa) AS UnitaOperativaCodice
					, (SELECT CodiceAzienda FROM [UnitaOperative] WHERE ID = IDUnitaOperativa) AS UnitaOperativaAzienda
					, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaRichiedente) AS SistemaRichiedenteCodice
					, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaRichiedente) AS SistemaRichiedenteAzienda
					
				FROM [dbo].[Ennuple] AS Ennupla
				WHERE IDGruppoUtenti = Gruppo.ID
				ORDER BY Descrizione
				FOR XML AUTO
			)) AS Ennuple	
	
		--[Utenti]
		, CONVERT(xml, (
				SELECT Gruppo.ID AS IDGruppo,
						ID, Utente, Descrizione, Attivo, Delega
				FROM [dbo].[Utenti] AS Utente
				WHERE [ID] IN (
							SELECT IDUtente FROM [dbo].[UtentiGruppiUtenti] UGU
							WHERE UGU.IDGruppoUtenti = Gruppo.ID
							)
				ORDER BY Utente
				FOR XML AUTO
			)) AS Utenti
		
	FROM [dbo].[GruppiUtenti] AS Gruppo
	WHERE Gruppo.ID = @IDGruppoUtenti
		OR @IDGruppoUtenti IS NULL
	ORDER BY Descrizione

	FOR XML AUTO, ROOT('GruppiUtenti')
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MaintenanceExportUtentiPerGruppo] TO [ExecuteImportExport]
    AS [dbo];

