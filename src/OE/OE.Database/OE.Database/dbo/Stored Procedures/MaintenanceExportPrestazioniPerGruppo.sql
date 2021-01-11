
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-24
-- Create date: 2013-10-28 - Esporta anche i profili
-- Modify date: 2014-03-27 Aggiunto campo CodiceSinonimo a Prestazione
--						   Aggiunto campo CancellazionePostInoltro a Sistema
--						   Aggiunto campo Preferiti a Gruppo
-- Modify date: 2018-06-15 Aggiunto a Prestazione campo Note, RichiedibileSoloDaProfilo
--						   Aggiunto a ProfiloPrestazioni: campo Note
--						   Aggiunto a Prestazioni: nodo Profili
--
-- Description:	Esporta le configurazioni delle prestazioni
--				 e dati accessori di un gruppo di prestazioni
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceExportPrestazioniPerGruppo]
	@IDGruppoPrestazioni UNIQUEIDENTIFIER
AS
BEGIN

	SET NOCOUNT ON
  
	SELECT ID, Descrizione, Preferiti

		--[Sistemi]
		, CONVERT(xml, (	
			SELECT ID, Codice, Descrizione, Erogante, Richiedente, CodiceAzienda, Attivo, CancellazionePostInoltro
			  FROM [dbo].[Sistemi] AS Sistema
			  WHERE ID IN (
						SELECT DISTINCT P.IDSistemaErogante
						FROM [dbo].[PrestazioniGruppiPrestazioni] PGP
							INNER JOIN [dbo].[Prestazioni] P ON P.ID = PGP.IDPrestazione
						WHERE PGP.IDGruppoPrestazioni = Gruppo.ID
						)
				ORDER BY Codice
				FOR XML AUTO
			)) AS Sistemi
		
		--[Ennuple]
		, CONVERT(xml, (	
				SELECT ID, IDGruppoUtenti, IDGruppoPrestazioni, Descrizione, OrarioInizio, OrarioFine
							, Lunedi, Martedi, Mercoledi, Giovedi, Venerdi, Sabato, Domenica
							, IDUnitaOperativa, IDSistemaRichiedente, CodiceRegime, CodicePriorita, [Not], IDStato
							, (SELECT Codice FROM [UnitaOperative] WHERE ID = IDUnitaOperativa) AS UnitaOperativaCodice
							, (SELECT CodiceAzienda FROM [UnitaOperative] WHERE ID = IDUnitaOperativa) AS UnitaOperativaAzienda
							, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaRichiedente) AS SistemaRichiedenteCodice
							, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaRichiedente) AS SistemaRichiedenteAzienda
				FROM [dbo].[Ennuple] AS Ennupla
				WHERE IDGruppoPrestazioni = Gruppo.ID
			  	ORDER BY Descrizione

				FOR XML AUTO
			)) AS Ennuple	
	
		--[Prestazioni]
		, CONVERT(xml, (
			SELECT Gruppo.ID AS IDGruppo
					,ID, Codice, Descrizione, Tipo, Provenienza, IDSistemaErogante, Attivo, CodiceSinonimo, Note, RichiedibileSoloDaProfilo
					, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteCodice
					, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteAzienda

					, CONVERT(xml, (
							SELECT ID
							FROM [dbo].[Prestazioni] AS Profilo
							WHERE [ID] IN (
											SELECT DISTINCT PP.[IDPadre]
											FROM [dbo].[PrestazioniProfili] AS PP
											WHERE PP.[IDFiglio] = Prestazione.ID
											)
										AND [Tipo] IN (1,  2)
			  				ORDER BY Codice
							FOR XML AUTO
							)) AS Profili

				FROM [dbo].[Prestazioni] AS Prestazione
				WHERE [ID] IN (
								SELECT IDPrestazione FROM [dbo].[PrestazioniGruppiPrestazioni] PGP
								WHERE PGP.IDGruppoPrestazioni = Gruppo.ID
								)
			  	ORDER BY Codice
				FOR XML AUTO
			)) AS Prestazioni
			
		--[Profili]
		, CONVERT(xml, (
			SELECT Gruppo.ID AS IDGruppo
					,ID, Codice, Descrizione, Tipo, Provenienza, IDSistemaErogante, Attivo, Note
					, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteCodice
					, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteAzienda
				FROM [dbo].[Prestazioni] AS Profilo
				WHERE [ID] IN (
								SELECT DISTINCT PP.IDPadre
										FROM [dbo].[PrestazioniProfili] PP
											INNER JOIN [dbo].[PrestazioniGruppiPrestazioni] PGP
												ON PP.IDFiglio = PGP.IDPrestazione
								WHERE PGP.IDGruppoPrestazioni = Gruppo.ID
								)
					AND [Tipo] IN (1,  2)
			  	ORDER BY Codice
				FOR XML AUTO
			)) AS Profili
			
		--[DatiAccessori]
		, CONVERT(xml, (
			SELECT Codice, Descrizione, Etichetta, Tipo, Obbligatorio, Ripetibile, Valori, Ordinamento, Gruppo
					, ValidazioneRegex, ValidazioneMessaggio, Sistema, ValoreDefault, NomeDatoAggiuntivo
			FROM [dbo].[DatiAccessori] AS DatoAccessorio
			WHERE Codice IN (	SELECT CodiceDatoAccessorio
								  FROM [dbo].[DatiAccessoriPrestazioni]
								  WHERE IDPrestazione IN ( 
								  				SELECT IDPrestazione
								  				FROM [dbo].[PrestazioniGruppiPrestazioni] PGP
												WHERE PGP.IDGruppoPrestazioni = Gruppo.ID
														)
								UNION
								SELECT CodiceDatoAccessorio
									  FROM [dbo].[DatiAccessoriSistemi]
									  WHERE IDSistema IN (
												SELECT DISTINCT P.IDSistemaErogante
												FROM [dbo].[PrestazioniGruppiPrestazioni] PGP
													INNER JOIN [dbo].[Prestazioni] P ON P.ID = PGP.IDPrestazione
												WHERE PGP.IDGruppoPrestazioni = Gruppo.ID
												)
								)
				ORDER BY Codice
				FOR XML AUTO
			)) AS DatiAccessori	
			
		--[DatiAccessoriPrestazioni]
		, CONVERT(xml, (
			SELECT ID, CodiceDatoAccessorio, IDPrestazione, Attivo, Sistema, ValoreDefault
					, (SELECT Codice FROM [Prestazioni] WHERE ID = IDPrestazione) AS PrestazioneCodice
					, (SELECT S.Codice FROM [Sistemi] S INNER JOIN [Prestazioni] P ON S.ID = P.IDSistemaErogante
															WHERE P.ID = IDPrestazione) AS PrestazioneSistemaEroganteCodice
					, (SELECT S.CodiceAzienda FROM [Sistemi] S INNER JOIN [Prestazioni] P ON S.ID = P.IDSistemaErogante
															WHERE P.ID = IDPrestazione) AS PrestazioneSistemaEroganteAzienda
				FROM [dbo].[DatiAccessoriPrestazioni] AS DatoAccessorioPrestazione
				WHERE IDPrestazione IN (
								SELECT IDPrestazione FROM [dbo].[PrestazioniGruppiPrestazioni] PGP
								WHERE PGP.IDGruppoPrestazioni = Gruppo.ID
								)
				ORDER BY CodiceDatoAccessorio, IDPrestazione
				FOR XML AUTO
			)) AS DatiAccessoriPrestazioni

		--[DatiAccessoriSistemi]
		, CONVERT(xml, (
			SELECT ID, CodiceDatoAccessorio, IDSistema, Attivo, Sistema, ValoreDefault
					, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistema) AS SistemaEroganteCodice
					, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistema) AS SistemaEroganteAzienda
				FROM [dbo].[DatiAccessoriSistemi] AS DatoAccessorioSistema
				WHERE IDSistema IN (
								SELECT DISTINCT P.IDSistemaErogante
								FROM [dbo].[PrestazioniGruppiPrestazioni] PGP
									INNER JOIN [dbo].[Prestazioni] P ON P.ID = PGP.IDPrestazione
								WHERE PGP.IDGruppoPrestazioni = Gruppo.ID
								)
				ORDER BY CodiceDatoAccessorio, IDSistema
				FOR XML AUTO
			)) AS DatiAccessoriSistemi	

	FROM [dbo].[GruppiPrestazioni] AS Gruppo
	WHERE Gruppo.ID = @IDGruppoPrestazioni
		OR @IDGruppoPrestazioni IS NULL
	ORDER BY Descrizione
	FOR XML AUTO, ROOT('GruppiPrestazioni')

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MaintenanceExportPrestazioniPerGruppo] TO [ExecuteImportExport]
    AS [dbo];

