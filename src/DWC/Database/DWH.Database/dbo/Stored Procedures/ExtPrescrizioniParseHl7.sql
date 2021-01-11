





-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-16
-- Modify date: 2017-04-13 @DataPartizione puo essere NULL e non la usa nella ricerca
-- Modify date: 2017-06-22 ETTORE: aggiunto elenco dei campi in fase di insert cosi posso mappare correttamente i campi "nuovi" che sono appesi alla tabella
-- Modify date: 2019-12-09 ETTORE: Il campo Prescrizione_Specialistiche_ClassePriorita è stato ridimensionato a 20 caratteri [ASMN 7240]
-- 				   
-- Description:	Esegue il parsing dei dati HL7 della prescrizione
-- =============================================
CREATE PROCEDURE [dbo].[ExtPrescrizioniParseHl7](
 @IdPrescrizione uniqueidentifier
,@DataPartizione smalldatetime
,@NoInformation bit = 1
) AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Err INT = 0
		  , @Added INT = 0

	DECLARE @Prescrizioni TABLE (Id UNIQUEIDENTIFIER, DataPartizione SMALLDATETIME, TipoPrescrizione VARCHAR(16)
								, DataInserimento DATETIME, DataModifica DATETIME, xmlFile XML)

	BEGIN TRAN
	--
	-- Prende gli allegati, dovrebbe essercene 1 solo
	--
	INSERT @Prescrizioni (Id, DataPartizione, TipoPrescrizione, DataInserimento, DataModifica, xmlFile)
	SELECT s.Id, s.DataPartizione, s.TipoPrescrizione, s.DataInserimento, s.DataModifica
			, CONVERT(XML, dbo.decompress(pab.ContenutoCompresso))
	FROM [store].[PrescrizioniBase] s
			INNER JOIN [store].[PrescrizioniAllegatiBase] pab
					ON pab.[IdPrescrizioniBase] = s.Id
					AND pab.[DataPartizione] = s.DataPartizione
					AND pab.[TipoContenuto] = 'text/xml'
	WHERE s.Id = @IdPrescrizione
		AND (s.DataPartizione = @DataPartizione OR @DataPartizione IS NULL)
	ORDER BY pab.DataModifica DESC
	
	SELECT @Err = @@ERROR, @Added = @@ROWCOUNT
	IF @NoInformation = 0
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Trovati allegati ' + CONVERT(VARCHAR(10), @Added)
	IF @Err <> 0 GOTO ERR_EXIT
	--
	-- Cancella se esiste già
	--
	IF EXISTS (SELECT * FROM @Prescrizioni p
						INNER JOIN [store].[PrescrizioniEstesaTestata] pet
							ON p.Id = pet.IdPrescrizioniBase
							AND p.DataPartizione = pet.DataPartizione)
	BEGIN
		IF @NoInformation = 0
			PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Inizio cancellazione'
		
		DELETE FROM [store].[PrescrizioniEstesaFarmaceutica]
		WHERE EXISTS ( SELECT * FROM @Prescrizioni p
						WHERE p.Id = [PrescrizioniEstesaFarmaceutica].IdPrescrizioniBase
							AND p.DataPartizione = [PrescrizioniEstesaFarmaceutica].DataPartizione)

		SELECT @Err = @@ERROR, @Added = @@ROWCOUNT
		IF @NoInformation = 0
			PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Cancella Farmaceutica ' + CONVERT(VARCHAR(10), @Added)
		IF @Err <> 0 GOTO ERR_EXIT

		DELETE FROM [store].[PrescrizioniEstesaSpecialistica]
		WHERE EXISTS ( SELECT * FROM @Prescrizioni p
						WHERE p.Id = [PrescrizioniEstesaSpecialistica].IdPrescrizioniBase
							AND p.DataPartizione = [PrescrizioniEstesaSpecialistica].DataPartizione)
			
		SELECT @Err = @@ERROR, @Added = @@ROWCOUNT
		IF @NoInformation = 0
			PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Cancella Specialistica ' + CONVERT(VARCHAR(10), @Added)
		IF @Err <> 0 GOTO ERR_EXIT

		DELETE FROM [store].[PrescrizioniEstesaTestata]
		WHERE EXISTS ( SELECT * FROM @Prescrizioni p
						WHERE p.Id = [PrescrizioniEstesaTestata].IdPrescrizioniBase
							AND p.DataPartizione = [PrescrizioniEstesaTestata].DataPartizione)
		
		SELECT @Err = @@ERROR, @Added = @@ROWCOUNT
		IF @NoInformation = 0
			PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Cancella testate ' + CONVERT(VARCHAR(10), @Added)
		IF @Err <> 0 GOTO ERR_EXIT
	END	
	--
	-- Inserisco dati TESTATA
	--
	IF @NoInformation = 0
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Inizio inserimento'

	INSERT [store].[PrescrizioniEstesaTestata]
	(
	[IdPrescrizioniBase],[DataPartizione],[TipoPrescrizione],[DataInserimento],[DataModifica]
	,[InformazioniTecniche_Promemoria],[InformazioniTecniche_MacAddressPrescrittore]
	,[InformazioniTecniche_SwPrescrittore],[Medico_Titolare_CodiceFiscale],[Medico_Titolare_CodRegionale],[Medico_Titolare_Cognome],[Medico_Titolare_Nome],[Medico_Titolare_CodTipoSpecializzazione]
	,[Medico_Titolare_CodRegione],[Medico_Titolare_CodAzienda],[Medico_Titolare_CodStruttura],[Medico_Titolare_Indirizzo],[Medico_Prescrittore_CodiceFiscale],[Medico_Prescrittore_CodRegionale]
	,[Medico_Prescrittore_Cognome],[Medico_Prescrittore_Nome],[Medico_Prescrittore_CodTipoSpecializzazione],[Medico_Prescrittore_CodAzienda],[Medico_Prescrittore_DescAzienda],[Medico_Prescrittore_Indirizzo]
	,[Paziente_DocumentiIdentita_CodiceFiscale],[Paziente_DocumentiIdentita_TesseraSanitaria],[Paziente_DocumentiIdentita_STP],[Paziente_DocumentiIdentita_ENI],[Paziente_DocumentiIdentita_NumeroIdPersonale]
	,[Paziente_DocumentiIdentita_CodStatoEstero],[Paziente_DocumentiIdentita_DescStatoEstero],[Paziente_DocumentiIdentita_TsEuropea],[Paziente_DocumentiIdentita_ScandenzaTS],[Paziente_DocumentiIdentita_IstituzioneTS]
	,[Paziente_DocumentiIdentita_TesseraSASN],[Paziente_DocumentiIdentita_CodAuslAppartenenza],[Paziente_DocumentiIdentita_DescAuslAppartenenza],[Paziente_DocumentiIdentita_MatricolaCIIP],[Paziente_DocumentiIdentita_CodSocietaNavigazione]
	,[Paziente_DocumentiIdentita_DescSocietaNavigazione],[Paziente_DatiAnagrafici_Cognome],[Paziente_DatiAnagrafici_Nome],[Paziente_DatiAnagrafici_Sesso],[Paziente_DatiAnagrafici_DataNascita]
	,[Paziente_DatiAnagrafici_CodComuneNascita],[Paziente_DatiAnagrafici_DescComuneNascita],[Paziente_DatiAnagrafici_CodCittadinanza],[Paziente_DatiAnagrafici_DescCittadinanza],[Paziente_Indirizzi_IndirizzoResidenza]
	,[Paziente_Indirizzi_CodComuneResidenza],[Paziente_Indirizzi_DescComuneResidenza],[Paziente_Indirizzi_CodRegioneResidenza],[Paziente_Indirizzi_CapResidenza],[Paziente_Indirizzi_ProvResidenza]
	,[Paziente_Indirizzi_IndirizzoDomicilio],[Paziente_Indirizzi_CodComuneDomicilio],[Paziente_Indirizzi_DescComuneDomicilio],[Paziente_Indirizzi_CodRegioneDomicilio],[Paziente_Indirizzi_CapDomicilio]
	,[Paziente_Indirizzi_ProvDomicilio],[Paziente_Indirizzi_Telefono],[Paziente_Indirizzi_Email],[Paziente_ASL_CodAslAssistenza],[Paziente_ASL_DescAslAssistenza],[Paziente_ASL_CodAslResidenza]
	,[Paziente_ASL_DescAslResidenza],[Paziente_Altro_ConsensoFseRegionale],[Prescrizione_InformazioniGenerali_Nre],[Prescrizione_InformazioniGenerali_IdRegionale]
	,[Prescrizione_InformazioniGenerali_Data]
	,[Prescrizione_InformazioniGenerali_TipoPrescrizione],[Prescrizione_InformazioniGenerali_Esenzione],[Prescrizione_InformazioniGenerali_CodTipoVisita],[Prescrizione_InformazioniGenerali_CodTipoRicetta]
	,[Prescrizione_InformazioniGenerali_PrescrizioneUsoInterno],[Prescrizione_InformazioniGenerali_CodTipoIndicazione],[Prescrizione_InformazioniGenerali_OscuramentoDatiAnagr],[Prescrizione_InformazioniGenerali_TotaleConfezioniPrestazioni]
	,[Prescrizione_Note_PropostaTerapeutica],[Prescrizione_Note_CodQuesitoDiagnostico],[Prescrizione_Note_DescQuesitoDiagnostico],[Prescrizione_Note_NoteUsoRegionale],[Prescrizione_Specialistiche_Priorita]
	,[Prescrizione_Specialistiche_IdRegionalePrescrizioneRiferimento],[Prescrizione_Specialistiche_NrePrescrizioneRiferimento],[Prescrizione_Specialistiche_VersioneCatalogoPrestRegionale]
	,[Prescrizione_Specialistiche_PrestFuoriCatalogoRegionale],[Prescrizione_Rossa_BarCodeCF],[Prescrizione_Farmaceutiche_VersioneProntuarioFarmRegionale],[Prescrizione_Farmaceutiche_FarmaciSenzaPA]
	)
	SELECT p.Id AS IdPrescrizioniBase
			, p.DataPartizione, p.TipoPrescrizione
			, p.DataInserimento, p.DataModifica
			,T.[InformazioniTecniche_Promemoria],T.[InformazioniTecniche_MacAddressPrescrittore]
			,T.[InformazioniTecniche_SwPrescrittore],T.[Medico_Titolare_CodiceFiscale],T.[Medico_Titolare_CodRegionale],T.[Medico_Titolare_Cognome],T.[Medico_Titolare_Nome],T.[Medico_Titolare_CodTipoSpecializzazione]
			,T.[Medico_Titolare_CodRegione],T.[Medico_Titolare_CodAzienda],T.[Medico_Titolare_CodStruttura],T.[Medico_Titolare_Indirizzo],T.[Medico_Prescrittore_CodiceFiscale],T.[Medico_Prescrittore_CodRegionale]
			,T.[Medico_Prescrittore_Cognome],T.[Medico_Prescrittore_Nome],T.[Medico_Prescrittore_CodTipoSpecializzazione],T.[Medico_Prescrittore_CodAzienda],T.[Medico_Prescrittore_DescAzienda],T.[Medico_Prescrittore_Indirizzo]
			,T.[Paziente_DocumentiIdentita_CodiceFiscale],T.[Paziente_DocumentiIdentita_TesseraSanitaria],T.[Paziente_DocumentiIdentita_STP],T.[Paziente_DocumentiIdentita_ENI],T.[Paziente_DocumentiIdentita_NumeroIdPersonale]
			,T.[Paziente_DocumentiIdentita_CodStatoEstero],T.[Paziente_DocumentiIdentita_DescStatoEstero],T.[Paziente_DocumentiIdentita_TsEuropea],T.[Paziente_DocumentiIdentita_ScandenzaTS],T.[Paziente_DocumentiIdentita_IstituzioneTS]
			,T.[Paziente_DocumentiIdentita_TesseraSASN],T.[Paziente_DocumentiIdentita_CodAuslAppartenenza],T.[Paziente_DocumentiIdentita_DescAuslAppartenenza],T.[Paziente_DocumentiIdentita_MatricolaCIIP],T.[Paziente_DocumentiIdentita_CodSocietaNavigazione]
			,T.[Paziente_DocumentiIdentita_DescSocietaNavigazione],T.[Paziente_DatiAnagrafici_Cognome],T.[Paziente_DatiAnagrafici_Nome],T.[Paziente_DatiAnagrafici_Sesso],T.[Paziente_DatiAnagrafici_DataNascita]
			,T.[Paziente_DatiAnagrafici_CodComuneNascita],T.[Paziente_DatiAnagrafici_DescComuneNascita],T.[Paziente_DatiAnagrafici_CodCittadinanza],T.[Paziente_DatiAnagrafici_DescCittadinanza],T.[Paziente_Indirizzi_IndirizzoResidenza]
			,T.[Paziente_Indirizzi_CodComuneResidenza],T.[Paziente_Indirizzi_DescComuneResidenza],T.[Paziente_Indirizzi_CodRegioneResidenza],T.[Paziente_Indirizzi_CapResidenza],T.[Paziente_Indirizzi_ProvResidenza]
			,T.[Paziente_Indirizzi_IndirizzoDomicilio],T.[Paziente_Indirizzi_CodComuneDomicilio],T.[Paziente_Indirizzi_DescComuneDomicilio],T.[Paziente_Indirizzi_CodRegioneDomicilio],T.[Paziente_Indirizzi_CapDomicilio]
			,T.[Paziente_Indirizzi_ProvDomicilio],T.[Paziente_Indirizzi_Telefono],T.[Paziente_Indirizzi_Email],T.[Paziente_ASL_CodAslAssistenza],T.[Paziente_ASL_DescAslAssistenza],T.[Paziente_ASL_CodAslResidenza]
			,T.[Paziente_ASL_DescAslResidenza],T.[Paziente_Altro_ConsensoFseRegionale],T.[Prescrizione_InformazioniGenerali_Nre],T.[Prescrizione_InformazioniGenerali_IdRegionale]
			--MODIFICA ETTORE: 2017-06-26 Per ora il campo della tabella è ancora un VARCHAR(128), ma la function lo estrae come DATETIME, quindi faccio un CAST a VARCHAR(128) in formato serializzabile
			,CONVERT(varchar(128), T.[Prescrizione_InformazioniGenerali_Data], 121) AS Prescrizione_InformazioniGenerali_Data
			,T.[Prescrizione_InformazioniGenerali_TipoPrescrizione],T.[Prescrizione_InformazioniGenerali_Esenzione],T.[Prescrizione_InformazioniGenerali_CodTipoVisita],T.[Prescrizione_InformazioniGenerali_CodTipoRicetta]
			,T.[Prescrizione_InformazioniGenerali_PrescrizioneUsoInterno],T.[Prescrizione_InformazioniGenerali_CodTipoIndicazione],T.[Prescrizione_InformazioniGenerali_OscuramentoDatiAnagr],T.[Prescrizione_InformazioniGenerali_TotaleConfezioniPrestazioni]
			,T.[Prescrizione_Note_PropostaTerapeutica],T.[Prescrizione_Note_CodQuesitoDiagnostico],T.[Prescrizione_Note_DescQuesitoDiagnostico],T.[Prescrizione_Note_NoteUsoRegionale],T.[Prescrizione_Specialistiche_Priorita]
			,T.[Prescrizione_Specialistiche_IdRegionalePrescrizioneRiferimento],T.[Prescrizione_Specialistiche_NrePrescrizioneRiferimento],T.[Prescrizione_Specialistiche_VersioneCatalogoPrestRegionale]
			,T.[Prescrizione_Specialistiche_PrestFuoriCatalogoRegionale],T.[Prescrizione_Rossa_BarCodeCF],T.[Prescrizione_Farmaceutiche_VersioneProntuarioFarmRegionale],T.[Prescrizione_Farmaceutiche_FarmaciSenzaPA]
	FROM @Prescrizioni p
		CROSS APPLY [dbo].[GetPrescrizioniHL7Testata](p.xmlFile) T
	ORDER BY p.DataPartizione

	SELECT @Err = @@ERROR, @Added = @@ROWCOUNT
	IF @NoInformation = 0
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Aggiunte testate ' + CONVERT(VARCHAR(10), @Added)
	IF @Err <> 0 GOTO ERR_EXIT
	--
	-- Inserisco dati Farmaceutica
	--
	INSERT [store].[PrescrizioniEstesaFarmaceutica]
	SELECT p.Id, p.DataPartizione
		, ROW_NUMBER() OVER(PARTITION BY p.Id ORDER BY p.DataPartizione) AS Riga
		, p.DataInserimento, p.DataModifica
		, F.*
	FROM @Prescrizioni p
		CROSS APPLY [dbo].[GetPrescrizioniHL7Farmaceutica](p.xmlFile) F
	WHERE p.TipoPrescrizione = 'Farmaceutica'
	ORDER BY p.DataPartizione

	SELECT @Err = @@ERROR, @Added = @@ROWCOUNT
	IF @NoInformation = 0
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Aggiunte farmaceutica ' + CONVERT(VARCHAR(10), @Added)
	IF @Err <> 0 GOTO ERR_EXIT
	--
	-- Inserisco dati Specialistica
	--
	INSERT [store].[PrescrizioniEstesaSpecialistica]
	SELECT p.Id, p.DataPartizione
		, ROW_NUMBER() OVER(PARTITION BY p.Id ORDER BY p.DataPartizione) AS Riga
		, p.DataInserimento, p.DataModifica
		, S.*
	FROM @Prescrizioni p
		CROSS APPLY [dbo].[GetPrescrizioniHL7Specialistica](p.xmlFile) S
	WHERE p.TipoPrescrizione = 'Specialistica'
	ORDER BY p.DataPartizione

	SELECT @Err = @@ERROR, @Added = @@ROWCOUNT
	IF @NoInformation = 0
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Aggiunte specialistica ' + CONVERT(VARCHAR(10), @Added)
	IF @Err <> 0 GOTO ERR_EXIT
	--
	-- Fine OK
	--
	COMMIT
	RETURN 0
	GOTO OK_EXIT

ERR_EXIT:
	--
	-- Errore
	--
	IF @@TRANCOUNT > 0
		ROLLBACK
		
	IF @NoInformation = 0
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Errore ' + CONVERT(VARCHAR(10), @Err)

OK_EXIT:

	RETURN @Err
END