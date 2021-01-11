
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-10-28
-- Modify date: 2014-03-27 Aggiunto campo CodiceSinonimo a Prestazione
-- Modify date: 2016-04-21 Rimosso filtro LIKE 'ADM%'
-- Modify date: 2018-06-15 Aggiunto a Prestazione: campo Note e RichiedibileSoloDaProfilo
--						   Aggiunto a ProfiloPrestazioni: campo Note
--						   Aggiunto a Prestazioni: nodo Gruppi
--
-- Description:	Esporta le configurazioni delle prestazioni
--				 e dati accessori di un profilo di prestazioni
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceExportPrestazioniPerProfilo]
	@IDProfiloPrestazioni UNIQUEIDENTIFIER
AS
BEGIN

	SET NOCOUNT ON
  
	SELECT ProfiloPrestazioni.ID, Codice, Descrizione, Tipo, Provenienza, IDSistemaErogante, Attivo, Note

		--[Sistemi]
		, CONVERT(xml, (	
			SELECT ID, Codice, Descrizione, Erogante, Richiedente, CodiceAzienda, Attivo
			  FROM [dbo].[Sistemi] AS Sistema
			  WHERE ID IN (
						SELECT DISTINCT P.IDSistemaErogante
						FROM [Prestazioni] P 
							INNER JOIN [dbo].[PrestazioniProfili] AS PP	ON P.ID = PP.IDFiglio
						WHERE PP.IDPadre = ProfiloPrestazioni.ID
						)
					AND ID <> '00000000-0000-0000-0000-000000000000'
				ORDER BY Codice
				FOR XML AUTO
			)) AS Sistemi

		--[Prestazioni]
		, CONVERT(xml, (
			SELECT ProfiloPrestazioni.ID AS IDProfiloPrestazioni
					, ProfiloPrestazioni.Codice AS CodiceProfiloPrestazioni
					, ProfiloPrestazioni.[IDSistemaErogante] AS IDSistemaProfiloPrestazioni
					, ID, Codice, Descrizione, Tipo, Provenienza, IDSistemaErogante, Attivo, CodiceSinonimo
					, Note, RichiedibileSoloDaProfilo
					, (SELECT Codice FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteCodice
					, (SELECT CodiceAzienda FROM [Sistemi] WHERE ID = IDSistemaErogante) AS SistemaEroganteAzienda

					, CONVERT(xml, (
							SELECT ID, Descrizione, Preferiti, Note
							FROM [dbo].[GruppiPrestazioni] AS Gruppo
							WHERE [ID] IN (
											SELECT DISTINCT PGP.[IDGruppoPrestazioni]
											FROM [dbo].[PrestazioniGruppiPrestazioni] AS PGP
											WHERE PGP.[IDPrestazione] = Prestazione.ID
											)
			  					ORDER BY Descrizione
								FOR XML AUTO
							)) AS Gruppi

				FROM [dbo].[Prestazioni] AS Prestazione
				WHERE [ID] IN (
								SELECT DISTINCT PP.IDFiglio
								FROM [dbo].[PrestazioniProfili] AS PP
								WHERE PP.IDPadre = ProfiloPrestazioni.ID
								)
			  	ORDER BY Codice
				FOR XML AUTO
			)) AS Prestazioni

		--[GruppiPrestazioni]
		, CONVERT(xml, (
				SELECT ID, Descrizione, Preferiti, Note
				FROM [dbo].[GruppiPrestazioni] AS Gruppo
				WHERE [ID] IN (
								SELECT DISTINCT PGP.[IDGruppoPrestazioni]
								FROM [dbo].[PrestazioniGruppiPrestazioni] AS PGP
									INNER JOIN [dbo].[PrestazioniProfili] AS PP	ON PGP.[IDPrestazione] = PP.IDFiglio
								WHERE PP.[IDPadre] = ProfiloPrestazioni.ID
								)
			  	ORDER BY Descrizione
				FOR XML AUTO
			)) AS Gruppi
			
		--[DatiAccessori]
		, CONVERT(xml, (
			SELECT Codice, Descrizione, Etichetta, Tipo, Obbligatorio, Ripetibile, Valori, Ordinamento, Gruppo
					, ValidazioneRegex, ValidazioneMessaggio, Sistema, ValoreDefault, NomeDatoAggiuntivo
			FROM [dbo].[DatiAccessori] AS DatoAccessorio
			WHERE Codice IN (	SELECT CodiceDatoAccessorio
								  FROM [dbo].[DatiAccessoriPrestazioni]
								  WHERE IDPrestazione IN ( 
												SELECT DISTINCT P.ID
												FROM [Prestazioni] P 
													INNER JOIN [dbo].[PrestazioniProfili] AS PP	ON P.ID = PP.IDFiglio
												WHERE PP.IDPadre = ProfiloPrestazioni.ID
												)
								UNION
								SELECT CodiceDatoAccessorio
									  FROM [dbo].[DatiAccessoriSistemi]
									  WHERE IDSistema IN (
												SELECT DISTINCT P.IDSistemaErogante
												FROM [Prestazioni] P 
													INNER JOIN [dbo].[PrestazioniProfili] AS PP	ON P.ID = PP.IDFiglio
												WHERE PP.IDPadre = ProfiloPrestazioni.ID
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
											SELECT DISTINCT P.ID
											FROM [Prestazioni] P 
												INNER JOIN [dbo].[PrestazioniProfili] AS PP	ON P.ID = PP.IDFiglio
											WHERE PP.IDPadre = ProfiloPrestazioni.ID
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
											FROM [Prestazioni] P 
												INNER JOIN [dbo].[PrestazioniProfili] AS PP	ON P.ID = PP.IDFiglio
											WHERE PP.IDPadre = ProfiloPrestazioni.ID
									)
				ORDER BY CodiceDatoAccessorio, IDSistema
				FOR XML AUTO
			)) AS DatiAccessoriSistemi	

	FROM [dbo].[Prestazioni] AS ProfiloPrestazioni 
	WHERE ProfiloPrestazioni.Tipo IN ( 1, 2)
		AND (ProfiloPrestazioni.ID = @IDProfiloPrestazioni
			OR @IDProfiloPrestazioni IS NULL
			)
		
	ORDER BY ProfiloPrestazioni.Codice
	FOR XML AUTO, ROOT('ProfiliPrestazioni')
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MaintenanceExportPrestazioniPerProfilo] TO [ExecuteImportExport]
    AS [dbo];

