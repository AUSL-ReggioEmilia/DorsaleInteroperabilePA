
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-24
-- Modify date: 2014-03-27 Aggiunto campo CodiceSinonimo a Prestazione
--						   Aggiunto campo CancellazionePostInoltro a Sistema
-- Description:	Esporta le configurazioni delle ennuple-accessi
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceExportEnnupleAccessi]
	@IDEnnuplaAccessi UNIQUEIDENTIFIER
	,@Utenti BIT = 0
	,@Prestazioni BIT = 0
AS
BEGIN

	SET NOCOUNT ON
  
		SELECT ID, IDGruppoUtenti, Descrizione, IDSistemaErogante, R, I, S, [Not], IDStato
			, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteCodice
			, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteAzienda

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
				WHERE [ID] = EnnuplaAccessi.IDGruppoUtenti
				ORDER BY Descrizione
				FOR XML AUTO
			)) AS GruppiUtenti

		--[Sistemi
		, CONVERT(xml, (
			SELECT ID, Codice, Descrizione, Erogante, Richiedente, CodiceAzienda, Attivo, CancellazionePostInoltro
				
			--[Prestazioni]
			, CASE WHEN @Prestazioni = 1 THEN
					CONVERT(xml, (
						SELECT ID, Codice, Descrizione, Tipo, Provenienza, IDSistemaErogante, Attivo, CodiceSinonimo
							, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteCodice
							, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteAzienda
						FROM [dbo].[Prestazioni] AS Prestazione
						WHERE [IDSistemaErogante] = Sistema.ID
						ORDER BY Codice
						FOR XML AUTO
					))
					ELSE NULL END AS Prestazioni
				
					FROM [dbo].[Sistemi] AS Sistema
					WHERE [ID] = EnnuplaAccessi.IDSistemaErogante
					ORDER BY Codice
					FOR XML AUTO
				)) AS Sistemi
			
	FROM [dbo].[EnnupleAccessi] AS EnnuplaAccessi
	WHERE EnnuplaAccessi.ID = @IDEnnuplaAccessi
		OR @IDEnnuplaAccessi IS NULL

	FOR XML AUTO, ROOT('EnnupleAccessi')
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MaintenanceExportEnnupleAccessi] TO [ExecuteImportExport]
    AS [dbo];

