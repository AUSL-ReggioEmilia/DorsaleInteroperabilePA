
-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-11-22
-- Description:	Restituisce le informazioni di testata relative alla prescrizione estesa
-- =============================================
CREATE PROCEDURE [ws3].[PrescrizioneEstesaById]
(
  @IdToken UNIQUEIDENTIFIER
 ,@IdPrescrizioniBase UNIQUEIDENTIFIER
)
AS
BEGIN
/*
	Per ora viene passato @IdToken ma non viene utilizzato
*/
	SET NOCOUNT ON

	SELECT 
		 [IdPrescrizioniBase]
		,[DataPartizione]
		,[TipoPrescrizione]
		,[DataInserimento]
		,[DataModifica]
		,[InformazioniTecniche_Promemoria]
		,[InformazioniTecniche_MacAddressPrescrittore]
		,[InformazioniTecniche_SwPrescrittore]
		,[Medico_Titolare_CodiceFiscale]
		,[Medico_Titolare_CodRegionale]
		,[Medico_Titolare_Cognome]
		,[Medico_Titolare_Nome]
		,[Medico_Titolare_CodTipoSpecializzazione]
		,[Medico_Titolare_CodRegione]
		,[Medico_Titolare_CodAzienda]
		,[Medico_Titolare_CodStruttura]
		,[Medico_Titolare_Indirizzo]
		,[Medico_Prescrittore_CodiceFiscale]
		,[Medico_Prescrittore_CodRegionale]
		,[Medico_Prescrittore_Cognome]
		,[Medico_Prescrittore_Nome]
		,[Medico_Prescrittore_CodTipoSpecializzazione]
		,[Medico_Prescrittore_CodAzienda]
		,[Medico_Prescrittore_DescAzienda]
		,[Medico_Prescrittore_Indirizzo]
		,[Paziente_DocumentiIdentita_CodiceFiscale]
		,[Paziente_DocumentiIdentita_TesseraSanitaria]
		,[Paziente_DocumentiIdentita_STP]
		,[Paziente_DocumentiIdentita_ENI]
		,[Paziente_DocumentiIdentita_NumeroIdPersonale]
		,[Paziente_DocumentiIdentita_CodStatoEstero]
		,[Paziente_DocumentiIdentita_DescStatoEstero]
		,[Paziente_DocumentiIdentita_TsEuropea]
		,[Paziente_DocumentiIdentita_ScandenzaTS]
		,[Paziente_DocumentiIdentita_IstituzioneTS]
		,[Paziente_DocumentiIdentita_TesseraSASN]
		,[Paziente_DocumentiIdentita_CodAuslAppartenenza]
		,[Paziente_DocumentiIdentita_DescAuslAppartenenza]
		,[Paziente_DocumentiIdentita_MatricolaCIIP]
		,[Paziente_DocumentiIdentita_CodSocietaNavigazione]
		,[Paziente_DocumentiIdentita_DescSocietaNavigazione]
		,[Paziente_DatiAnagrafici_Cognome]
		,[Paziente_DatiAnagrafici_Nome]
		,[Paziente_DatiAnagrafici_Sesso]
		,[Paziente_DatiAnagrafici_DataNascita]
		,[Paziente_DatiAnagrafici_CodComuneNascita]
		,[Paziente_DatiAnagrafici_DescComuneNascita]
		,[Paziente_DatiAnagrafici_CodCittadinanza]
		,[Paziente_DatiAnagrafici_DescCittadinanza]
		,[Paziente_Indirizzi_IndirizzoResidenza]
		,[Paziente_Indirizzi_CodComuneResidenza]
		,[Paziente_Indirizzi_DescComuneResidenza]
		,[Paziente_Indirizzi_CodRegioneResidenza]
		,[Paziente_Indirizzi_CapResidenza]
		,[Paziente_Indirizzi_ProvResidenza]
		,[Paziente_Indirizzi_IndirizzoDomicilio]
		,[Paziente_Indirizzi_CodComuneDomicilio]
		,[Paziente_Indirizzi_DescComuneDomicilio]
		,[Paziente_Indirizzi_CodRegioneDomicilio]
		,[Paziente_Indirizzi_CapDomicilio]
		,[Paziente_Indirizzi_ProvDomicilio]
		,[Paziente_Indirizzi_Telefono]
		,[Paziente_Indirizzi_Email]
		,[Paziente_ASL_CodAslAssistenza]
		,[Paziente_ASL_DescAslAssistenza]
		,[Paziente_ASL_CodAslResidenza]
		,[Paziente_ASL_DescAslResidenza]
		,[Paziente_Altro_ConsensoFseRegionale]
		,[Prescrizione_InformazioniGenerali_Nre]
		,[Prescrizione_InformazioniGenerali_IdRegionale]
		,[Prescrizione_InformazioniGenerali_Data]
		,[Prescrizione_InformazioniGenerali_TipoPrescrizione]
		,[Prescrizione_InformazioniGenerali_Esenzione]
		,[Prescrizione_InformazioniGenerali_CodTipoVisita]
		,[Prescrizione_InformazioniGenerali_CodTipoRicetta]
		,[Prescrizione_InformazioniGenerali_PrescrizioneUsoInterno]
		,[Prescrizione_InformazioniGenerali_CodTipoIndicazione]
		,[Prescrizione_InformazioniGenerali_OscuramentoDatiAnagr]
		,[Prescrizione_InformazioniGenerali_TotaleConfezioniPrestazioni]
		,[Prescrizione_Note_PropostaTerapeutica]
		,[Prescrizione_Note_CodQuesitoDiagnostico]
		,[Prescrizione_Note_DescQuesitoDiagnostico]
		,[Prescrizione_Note_NoteUsoRegionale]
		,[Prescrizione_Specialistiche_Priorita]
		,[Prescrizione_Specialistiche_IdRegionalePrescrizioneRiferimento]
		,[Prescrizione_Specialistiche_NrePrescrizioneRiferimento]
		,[Prescrizione_Specialistiche_VersioneCatalogoPrestRegionale]
		,[Prescrizione_Specialistiche_PrestFuoriCatalogoRegionale]
		,[Prescrizione_Rossa_BarCodeCF]
		,[Prescrizione_Farmaceutiche_VersioneProntuarioFarmRegionale]
		,[Prescrizione_Farmaceutiche_FarmaciSenzaPA]
	FROM 
		[store].[PrescrizioniEstesaTestata]
	WHERE 
		IdPrescrizioniBase = @IdPrescrizioniBase
  
	RETURN @@ERROR
END