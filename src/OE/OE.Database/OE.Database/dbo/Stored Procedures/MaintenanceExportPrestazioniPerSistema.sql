
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-08
-- Modify date: 2013-10-11
-- Modify date: 2013-10-28 Esporta anche i profili
-- Modify date: 2014-03-27 Aggiunto campo CodiceSinonimo a Prestazione
--						Aggiunto campo CancellazionePostInoltro a Sistema
-- Modify date: 2018-06-15 Aggiunto a Prestazione: campo Note, RichiedibileSoloDaProfilo
--						   Aggiunto a ProfiloPrestazioni: campo Note
--
-- Description:	Esporta le configurazioni delle prestazioni
--				 e dati accessori di un sistema erogante
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceExportPrestazioniPerSistema]
	@CodiceAzienda VARCHAR(16)
	,@CodiceSistema VARCHAR(16)
AS
BEGIN

	SET NOCOUNT ON

	SELECT ID, Codice, Descrizione, Erogante, Richiedente, CodiceAzienda, Attivo, CancellazionePostInoltro
	
		--[EnnupleAccessi]
		, CONVERT(xml, (	
				SELECT ID, IDGruppoUtenti, Descrizione, IDSistemaErogante
					, R, I, S, [Not], IDStato
					, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteCodice
					, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteAzienda
				FROM [dbo].[EnnupleAccessi] AS EnnuplaAccesso
				WHERE IDSistemaErogante = Sistema.ID
				ORDER BY Descrizione

				FOR XML AUTO
			)) AS EnnupleAccessi	

		--[Prestazioni]
		, CONVERT(xml, (
			SELECT ID, Codice, Descrizione, Tipo, Provenienza, IDSistemaErogante, Attivo, CodiceSinonimo
					, Note, RichiedibileSoloDaProfilo
					, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteCodice
					, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteAzienda

					, CONVERT(xml, (
							SELECT ID--, Descrizione, Preferiti, Note
							FROM [dbo].[GruppiPrestazioni] AS Gruppo
							WHERE [ID] IN (
											SELECT DISTINCT PGP.[IDGruppoPrestazioni]
											FROM [dbo].[PrestazioniGruppiPrestazioni] AS PGP
											WHERE PGP.[IDPrestazione] = Prestazione.ID
											)
			  					ORDER BY Descrizione
								FOR XML AUTO
							)) AS Gruppi

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
				WHERE [IDSistemaErogante] = Sistema.ID
				ORDER BY Codice
				FOR XML AUTO
			)) AS Prestazioni
			
		--[Profili]
		, CONVERT(xml, (
			SELECT ID, Codice, Descrizione, Tipo, Provenienza, IDSistemaErogante, Attivo, Note
					, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteCodice
					, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteAzienda
				FROM [dbo].[Prestazioni] AS Profilo
				WHERE [ID] IN (
								SELECT DISTINCT PP.[IDPadre]
										FROM [dbo].[PrestazioniProfili] PP
											INNER JOIN [dbo].[Prestazioni] P
												ON PP.[IDFiglio] = P.[ID]
								WHERE P.[IDSistemaErogante] = Sistema.[ID]
								)
					AND [Tipo] IN (1,  2)
			  	ORDER BY Codice
				FOR XML AUTO
			)) AS Profili

		--[GruppiPrestazioni]
		, CONVERT(xml, (
				SELECT ID, Descrizione, Preferiti, Note
				FROM [dbo].[GruppiPrestazioni] AS Gruppo
				WHERE [ID] IN (
								SELECT DISTINCT PGP.[IDGruppoPrestazioni]
								FROM [dbo].[PrestazioniGruppiPrestazioni] AS PGP
									INNER JOIN [dbo].[Prestazioni] AS P	ON PGP.[IDPrestazione] = P.[ID]
								WHERE P.[IDSistemaErogante] = Sistema.[ID]
								)
			  	ORDER BY Descrizione
				FOR XML AUTO
			)) AS Gruppi
			
		--[DatiAccessoriPrestazioni]
		, CONVERT(xml, (
			SELECT ID, CodiceDatoAccessorio, IDPrestazione, Attivo, Sistema, ValoreDefault
					, (SELECT Codice FROM [Prestazioni] WHERE ID = IDPrestazione) AS PrestazioneCodice
					, (SELECT S.Codice FROM [Sistemi] S INNER JOIN [Prestazioni] P ON S.ID = P.IDSistemaErogante
															WHERE P.ID = IDPrestazione) AS PrestazioneSistemaEroganteCodice
					, (SELECT S.CodiceAzienda FROM [Sistemi] S INNER JOIN [Prestazioni] P ON S.ID = P.IDSistemaErogante
															WHERE P.ID = IDPrestazione) AS PrestazioneSistemaEroganteAzienda
			
				FROM [dbo].[DatiAccessoriPrestazioni] AS DatoAccessorioPrestazione
				WHERE IDPrestazione IN ( SELECT ID
										  FROM [dbo].[Prestazioni]
										  WHERE [IDSistemaErogante] = Sistema.ID)
				ORDER BY CodiceDatoAccessorio, IDPrestazione
				FOR XML AUTO
			)) AS DatiAccessoriPrestazioni

		--[DatiAccessoriSistemi]
		, CONVERT(xml, (
			SELECT ID, CodiceDatoAccessorio, IDSistema, Attivo, Sistema, ValoreDefault
					, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistema) AS SistemaEroganteCodice
					, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistema) AS SistemaEroganteAzienda
			
				FROM [dbo].[DatiAccessoriSistemi] AS DatoAccessorioSistema
				WHERE IDSistema = Sistema.ID
				ORDER BY CodiceDatoAccessorio, IDSistema
				FOR XML AUTO
			)) AS DatiAccessoriSistemi	

		--[DatiAccessori]
		, CONVERT(xml, (
			SELECT Codice, Descrizione, Etichetta, Tipo, Obbligatorio, Ripetibile, Valori, Ordinamento, Gruppo
					, ValidazioneRegex, ValidazioneMessaggio, Sistema, ValoreDefault, NomeDatoAggiuntivo
			FROM [dbo].[DatiAccessori] AS DatoAccessorio
			WHERE Codice IN (	SELECT CodiceDatoAccessorio
								  FROM [dbo].[DatiAccessoriPrestazioni]
								  WHERE IDPrestazione IN ( SELECT ID
									  FROM [dbo].[Prestazioni]
									  WHERE [IDSistemaErogante] = Sistema.ID)
								UNION
								SELECT CodiceDatoAccessorio
									  FROM [dbo].[DatiAccessoriSistemi]
									  WHERE IDSistema = Sistema.ID
								)
				ORDER BY Codice
				FOR XML AUTO
			)) AS DatiAccessori	
			
	FROM [dbo].[Sistemi] AS Sistema
	WHERE Erogante = 1
		AND EXISTS (SELECT *
				FROM [dbo].[Prestazioni] AS Prestazione
				WHERE [IDSistemaErogante] = Sistema.ID)
		
		AND ([Codice] = @CodiceSistema OR @CodiceSistema IS NULL)
		AND ([CodiceAzienda]= @CodiceAzienda OR @CodiceAzienda IS NULL)
	
	ORDER BY Codice, CodiceAzienda

	FOR XML AUTO, ROOT('Sistemi')

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MaintenanceExportPrestazioniPerSistema] TO [ExecuteImportExport]
    AS [dbo];

