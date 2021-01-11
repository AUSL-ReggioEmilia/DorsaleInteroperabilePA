

-- =============================================
-- Author:		Bitti Simone
-- Create date: 2016-10-18
-- Description:	Ritorna i dati letti dall'allegato XML
-- Modify Date: 2017-06-22 ETTORE: Gestione dell'uppercase nelle query xpath quando si filtra per un valore
--								   Valorizzazione dei campi Prescrizione_Specialistiche_XXX solo per prescrizioni specialistiche
--								   Valorizzazione dei campi PrescrizioneFarmaceutica_XXX solo per prescrizioni farmaceutiche
--								   Modificato il campo Prescrizione_Note_DescQuesitoDiagnostico da VARCHAR(300) a VARCHAR(2048)
--								   Modificato il campo Prescrizione_InformazioniGenerali_Data da VARCHAR(128) a DATETIME
-- Modify Date: 2019-12-09 ETTORE: Gestione della versione del messaggio 
--								   Il campo "Priorita" è stato ridimensionato a 20 caratteri e viene letto con XPATH differente [ASMN 7240]
-- Modify Date: 2020-07-24 ETTORE: Correzione per lettura del campo "Prescrizione_InformazioniGenerali_Esenzione"
-- =============================================
CREATE FUNCTION dbo.GetPrescrizioniHL7Testata
(
 @XmlFile AS XML
)
RETURNS @Ret TABLE (
	--INFORMAZIONI TECNICHE
	 InformazioniTecniche_Promemoria VARCHAR(MAX)
	,InformazioniTecniche_MacAddressPrescrittore VARCHAR(MAX)
	,InformazioniTecniche_SwPrescrittore VARCHAR(227)

	--MEDICO TITOLARE
	,Medico_Titolare_CodiceFiscale VARCHAR(60)
	,Medico_Titolare_CodRegionale VARCHAR(60)
	,Medico_Titolare_Cognome VARCHAR(60)
	,Medico_Titolare_Nome VARCHAR(60)
	,Medico_Titolare_CodTipoSpecializzazione VARCHAR(60)
	,Medico_Titolare_CodRegione VARCHAR(60)
	,Medico_Titolare_CodAzienda VARCHAR(60)
	,Medico_Titolare_CodStruttura VARCHAR(60)
	,Medico_Titolare_Indirizzo VARCHAR(60)

	--MEDICO PRESCRITTORE
	,Medico_Prescrittore_CodiceFiscale VARCHAR(250)
	,Medico_Prescrittore_CodRegionale VARCHAR(128)
	,Medico_Prescrittore_Cognome VARCHAR(250)
	,Medico_Prescrittore_Nome VARCHAR(250)
	,Medico_Prescrittore_CodTipoSpecializzazione VARCHAR(250)
	,Medico_Prescrittore_CodAzienda VARCHAR(128)
	,Medico_Prescrittore_DescAzienda VARCHAR(128)
	,Medico_Prescrittore_Indirizzo VARCHAR(128)

	--PAZIENTE - DOCUMENTI IDENTITA'
	,Paziente_DocumentiIdentita_CodiceFiscale VARCHAR(20)
	,Paziente_DocumentiIdentita_TesseraSanitaria VARCHAR(128)
	,Paziente_DocumentiIdentita_STP VARCHAR(20)
	,Paziente_DocumentiIdentita_ENI VARCHAR(20)
	,Paziente_DocumentiIdentita_NumeroIdPersonale VARCHAR(20)
	,Paziente_DocumentiIdentita_CodStatoEstero VARCHAR(20)
	,Paziente_DocumentiIdentita_DescStatoEstero VARCHAR(128)
	,Paziente_DocumentiIdentita_TsEuropea VARCHAR(20)
	,Paziente_DocumentiIdentita_ScandenzaTS DATE
	,Paziente_DocumentiIdentita_IstituzioneTS VARCHAR(20)
	,Paziente_DocumentiIdentita_TesseraSASN VARCHAR(20)
	,Paziente_DocumentiIdentita_CodAuslAppartenenza VARCHAR(20)
	,Paziente_DocumentiIdentita_DescAuslAppartenenza VARCHAR(20)
	,Paziente_DocumentiIdentita_MatricolaCIIP VARCHAR(20)
	,Paziente_DocumentiIdentita_CodSocietaNavigazione VARCHAR(20)
	,Paziente_DocumentiIdentita_DescSocietaNavigazione VARCHAR(20)

	--PAZIENTE - DATI ANAGRAFICI
	,Paziente_DatiAnagrafici_Cognome VARCHAR(48)
	,Paziente_DatiAnagrafici_Nome VARCHAR(48)
	,Paziente_DatiAnagrafici_Sesso VARCHAR(1)
	,Paziente_DatiAnagrafici_DataNascita DATETIME
	,Paziente_DatiAnagrafici_CodComuneNascita VARCHAR(106)
	,Paziente_DatiAnagrafici_DescComuneNascita VARCHAR(106)
	,Paziente_DatiAnagrafici_CodCittadinanza VARCHAR(80)
	,Paziente_DatiAnagrafici_DescCittadinanza VARCHAR(80)

	--PAZIENTE - INDIRIZZI
	,Paziente_Indirizzi_IndirizzoResidenza VARCHAR(106)
	,Paziente_Indirizzi_CodComuneResidenza VARCHAR(106)
	,Paziente_Indirizzi_DescComuneResidenza VARCHAR(106)
	,Paziente_Indirizzi_CodRegioneResidenza VARCHAR(106)
	,Paziente_Indirizzi_CapResidenza VARCHAR(106)
	,Paziente_Indirizzi_ProvResidenza VARCHAR(106)
	,Paziente_Indirizzi_IndirizzoDomicilio VARCHAR(106)
	,Paziente_Indirizzi_CodComuneDomicilio VARCHAR(106)
	,Paziente_Indirizzi_DescComuneDomicilio VARCHAR(106)
	,Paziente_Indirizzi_CodRegioneDomicilio VARCHAR(106)
	,Paziente_Indirizzi_CapDomicilio VARCHAR(106)
	,Paziente_Indirizzi_ProvDomicilio VARCHAR(106)
	,Paziente_Indirizzi_Telefono VARCHAR(40)
	,Paziente_Indirizzi_Email VARCHAR(40)

	--PAZIENTE - ASL
	,Paziente_ASL_CodAslAssistenza VARCHAR(90)
	,Paziente_ASL_DescAslAssistenza VARCHAR(90)
	,Paziente_ASL_CodAslResidenza VARCHAR(90)
	,Paziente_ASL_DescAslResidenza VARCHAR(90)
	
	--PAZIENTE - ALTRO
	,Paziente_Altro_ConsensoFseRegionale VARCHAR(MAX)
	
	--PRESCRIZIONE - INFORMAZIONI GENRALI
	,Prescrizione_InformazioniGenerali_Nre VARCHAR(22)
	,Prescrizione_InformazioniGenerali_IdRegionale VARCHAR(22)
	,Prescrizione_InformazioniGenerali_Data DATETIME
	,Prescrizione_InformazioniGenerali_TipoPrescrizione VARCHAR(15)
	,Prescrizione_InformazioniGenerali_Esenzione VARCHAR(MAX)
	,Prescrizione_InformazioniGenerali_CodTipoVisita VARCHAR(1)
	,Prescrizione_InformazioniGenerali_CodTipoRicetta VARCHAR(200)
	,Prescrizione_InformazioniGenerali_PrescrizioneUsoInterno BIT
	,Prescrizione_InformazioniGenerali_CodTipoIndicazione VARCHAR(250) --ROSSA: VARCHAR(200)

	-- Campo non trovato: DG1.3-CE.1 (Forse si trova dentro PD1.12?)
	,Prescrizione_InformazioniGenerali_OscuramentoDatiAnagr BIT
	,Prescrizione_InformazioniGenerali_TotaleConfezioniPrestazioni VARCHAR(10)

	--PRESCRIZIONE - NOTE
	,Prescrizione_Note_PropostaTerapeutica VARCHAR(MAX)
	,Prescrizione_Note_CodQuesitoDiagnostico VARCHAR(300)
	,Prescrizione_Note_DescQuesitoDiagnostico VARCHAR(2048)
	,Prescrizione_Note_NoteUsoRegionale VARCHAR(250) --ROSSA: VARCHAR(200)
	
	--PRESCRIZIONE - SPECIALISTICHE
	,Prescrizione_Specialistiche_Priorita VARCHAR(20)   --Modify Date: 2019-12-09 ETTORE: ridimensionato a 20 caratteri
	,Prescrizione_Specialistiche_IdRegionalePrescrizioneRiferimento VARCHAR(22)
	,Prescrizione_Specialistiche_NrePrescrizioneRiferimento VARCHAR(22)
	,Prescrizione_Specialistiche_VersioneCatalogoPrestRegionale VARCHAR(MAX)
	,Prescrizione_Specialistiche_PrestFuoriCatalogoRegionale BIT

	--PRESCRIZIONE - ROSSA
	,Prescrizione_Rossa_BarCodeCF BIT

	--PRESCRIZIONE - FARMACEUTICHE
	,Prescrizione_Farmaceutiche_VersioneProntuarioFarmRegionale VARCHAR(MAX)
	,Prescrizione_Farmaceutiche_FarmaciSenzaPA BIT
	)
AS
BEGIN

DECLARE @MessageType AS VARCHAR(128) = NULL
DECLARE @Farmaceutica AS BIT = NULL
DECLARE @Specialistica AS BIT= NULL
DECLARE @Versione AS VARCHAR(16) = ''

	-- Salvo nella variabile @MessageType che tipo di messaggio è
	;WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
						, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
						, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
	SELECT
	@MessageType = @XmlFile.value('(ns1:Message/ns0:Header/ns0:MessageType/ns0:MessageType)[1]', 'VARCHAR(128)');

	--MODIFICA ETTORE 2017-06-22: memorizzo se la prescrizione è di tipo FARMACEUTICA o SPECIALISTICA
	;WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
						, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
						, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
	SELECT @Specialistica  = @XmlFile.value('count(/ns1:Message/ns0:Order/ns0:ObservationRequest)[1]', 'BIT');

	;WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
						, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
						, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
	SELECT @Farmaceutica = @XmlFile.value('count(/ns1:Message/ns0:Order/ns0:PharmacyTreatmentOrder)[1]', 'BIT');


	--Modify Date: 2019-12-09 ETTORE :Gestione della versione del messaggio
	;WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
					, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
					, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
	SELECT @Versione  = @XmlFile.value('(/ns1:Message/ns0:Header/ns0:VersionId/ns2:InternationalVersionId/ns2:Identifier)[1]', 'VARCHAR(16)');
	IF @Versione IS NULL SET @Versione = ''


	-- Se @MessageType è OMG,ORG,OMP o ORP allora si tratta di un messaggio DEMA
	IF (@MessageType = 'OMG' OR @MessageType = 'ORG' OR @MessageType='OMP' OR @MessageType = 'ORP')
	BEGIN

		-- Legge i dati dall'allegato
		WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
						, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
						, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
		
		INSERT INTO @Ret
		SELECT 
		--INFORMAZIONI TECNICHE
		 @XmlFile.value('(/ns1:Message/ns0:NotesAndComments/ns0:CommentType[upper-case((ns2:Identifier)[1])=''STAMPA'']/ns2:Text)[1]', 'VARCHAR(MAX)') AS InformazioniTecniche_Promemoria
		,@XmlFile.value('(/ns1:Message/ns0:NotesAndComments/ns0:CommentType[upper-case((ns2:Identifier)[1])=''MAC'']/ns2:Text)[1]', 'VARCHAR(MAX)') AS InformazioniTecniche_MacAddressPrescrittore
		,@XmlFile.value('(/ns1:Message/ns0:Header/ns0:SendingApplication/ns2:NamespaceId)[1]', 'VARCHAR(227)') AS InformazioniTecniche_SwPrescrittore

		-- MEDICO TITOLARE
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) = ''NNITA'']/ns2:IdNumber)[1]', 'VARCHAR(60)') AS Medico_Titolare_CodiceFiscale
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) = ''CODMAT'']/ns2:IdNumber)[1]', 'VARCHAR(60)') AS Medico_Titolare_CodRegionale
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) = ''NNITA'']/ns2:FamilyName/ns2:Surname)[1]', 'VARCHAR(60)') AS Medico_Titolare_Cognome
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) = ''NNITA'']/ns2:GivenName)[1]', 'VARCHAR(60)') AS Medico_Titolare_Nome
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) = ''NNITA'']/ns2:DegreeEGMd)[1]', 'VARCHAR(60)') AS Medico_Titolare_CodTipoSpecializzazione
		
		-- ns2:AssigningJurisdiction/ns2:Identifier è un numero composto da 6 cifre: le prime 3 identificano il codice della regione
		,@XmlFile.value('substring((/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) = ''NNITA'']/ns2:AssigningJurisdiction/ns2:Identifier)[1],1,3)', 'VARCHAR(60)') AS Medico_Titolare_CodRegione
		,@XmlFile.value('substring((/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) = ''NNITA'']/ns2:AssigningJurisdiction/ns2:Identifier)[1],4,6)', 'VARCHAR(60)') AS Medico_Titolare_CodAzienda
		
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor/ns2:AssigningAgencyOrDepartment/ns2:Identifier)[1]', 'VARCHAR(60)') AS Medico_Titolare_CodStruttura
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor/ns2:AssigningFacility/ns2:NamespaceId)[1]', 'VARCHAR(60)') AS Medico_Titolare_Indirizzo
		
		--MEDICO PRESCRITTORE
		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:EnteredBy/ns2:IdNumber) return <a>{concat(",", $i)}</a>').value('.', 'varchar(250)'), 1, 1, '') as Medico_Prescrittore_CodiceFiscale
		,NULL AS Medico_Prescrittore_CodRegionale

		--,@XmlFile.value('(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:EnteredBy/ns2:FamilyName/ns2:Surname)[1]', 'VARCHAR(128)') AS Medico_Prescrittore_Cognome
		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:EnteredBy/ns2:FamilyName/ns2:Surname) return <a>{concat(",", $i)}</a>').value('.', 'varchar(250)'), 1, 1, '')AS Medico_Prescrittore_Cognome
		
		--,@XmlFile.value('(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:EnteredBy/ns2:GivenName)[1]', 'VARCHAR(128)') AS Medico_Prescrittore_Nome
		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:EnteredBy/ns2:GivenName) return <a>{concat(",", $i)}</a>').value('.', 'varchar(250)'), 1, 1, '')AS Medico_Prescrittore_Nome
		
		--,@XmlFile.value('(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:EnteredBy/ns2:DegreeEGMd)[1]', 'VARCHAR(128)') AS Medico_Prescrittore_CodTipoSpecializzazione
		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:EnteredBy/ns2:DegreeEGMd) return <a>{concat(",", $i)}</a>').value('.', 'varchar(250)'), 1, 1, '') AS Medico_Prescrittore_CodTipoSpecializzazione
		,NULL AS Medico_Prescrittore_CodAzienda
		,NULL AS Medico_Prescrittore_DescAzienda
		,NULL AS Medico_Prescrittore_Indirizzo

		--PAZIENTE - DOCUMENTI IDENTITA'
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''NNITA'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_CodiceFiscale
		,NULL AS Paziente_DocumentiIdentita_TesseraSanitaria
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''PNT'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_STP
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''ENI'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_ENI
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''ISO 3166-1 ALPHA-2'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_NumeroIdPersonale
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''ISO 3166-1 ALPHA-2'']/ns2:AssigningAuthority/ns2:NamespaceId)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_CodStatoEstero
		,NULL AS Paziente_DocumentiIdentita_DescStatoEstero
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''HC'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_TsEuropea
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''HC'']/ns2:ExpirationDate)[1]', 'DATE') AS Paziente_DocumentiIdentita_ScandenzaTS
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''HC'']/ns2:AssigningAuthority/ns2:NamespaceId)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_IstituzioneTS
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''SASN'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_TesseraSASN
		,NUll AS Paziente_DocumentiIdentita_CodAuslAppartenenza 
		,NULL AS Paziente_DocumentiIdentita_DescAuslAppartenenza
		,NULL AS Paziente_DocumentiIdentita_MatricolaCIIP
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''SASN'']/ns2:AssigningAuthority/ns2:NamespaceId)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_CodSocietaNavigazione
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''SASN'']/ns2:AssigningAuthority/ns2:UniversalId)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_DescSocietaNavigazione

		--PAZIENTE - DATI ANAGRAFICI
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientName/ns2:FamilyName/ns2:Surname)[1]', 'VARCHAR(48)') AS Paziente_DatiAnagrafici_Cognome
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientName/ns2:GivenName)[1]', 'VARCHAR(48)') AS Paziente_DatiAnagrafici_Nome
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:AdministrativeSex)[1]', 'VARCHAR(1)') AS Paziente_DatiAnagrafici_Sesso
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:DateTimeOfBirth/ns2:TS_Time)[1]', 'DATETIME') AS Paziente_DatiAnagrafici_DataNascita
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''N'']/ns2:CountyParishCode)[1]', 'VARCHAR(106)') AS Paziente_DatiAnagrafici_CodComuneNascita
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''N'']/ns2:City)[1]', 'VARCHAR(106)') AS Paziente_DatiAnagrafici_DescComuneNascita
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:Citizenship/ns2:AlternateIdentifier)[1]', 'VARCHAR(80)') AS Paziente_DatiAnagrafici_CodCittadinanza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:Citizenship/ns2:AlternateText)[1]', 'VARCHAR(80)') AS Paziente_DatiAnagrafici_DescCittadinanza

		--PAZIENTE - INDIRIZZI
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:StreetAddress/ns2:StreetOrMailingAddress)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_IndirizzoResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:CountyParishCode)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_CodComuneResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:City)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_DescComuneResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:StateOrProvince)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_CodRegioneResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:ZipOrPostalCode)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_CapResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:OtherGeographicDesignation)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_ProvResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''H'']/ns2:StreetAddress/ns2:StreetOrMailingAddress)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_IndirizzoDomicilio
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''H'']/ns2:CountyParishCode)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_CodComuneDomicilio
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''H'']/ns2:City)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_DescComuneDomicilio
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''H'']/ns2:StateOrProvince)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_CodRegioneDomicilio
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''H'']/ns2:ZipOrPostalCode)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_CapDomicilio
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''H'']/ns2:OtherGeographicDesignation)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_ProvDomicilio
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PhoneNumberHome[upper-case((ns2:TelecommunicationUseCode)[1]) =''PRN'']/ns2:UnformattedTelephoneNumber)[1]', 'VARCHAR(40)') AS Paziente_Indirizzi_Telefono
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PhoneNumberHome[upper-case((ns2:TelecommunicationUseCode)[1]) =''NET'']/ns2:UnformattedTelephoneNumber)[1]', 'VARCHAR(40)') AS Paziente_Indirizzi_Email
		
		--PAZIENTE - ASL
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientAdditionalDemographic/ns0:PatientPrimaryFacility[upper-case((ns2:IdentifierTypeCode)[1]) = ''ASLA'']/ns2:IdNumber)[1]', 'VARCHAR(90)') AS Paziente_ASL_CodAslAssistenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientAdditionalDemographic/ns0:PatientPrimaryFacility[upper-case((ns2:IdentifierTypeCode)[1]) = ''ASLA'']/ns2:OrganizationName)[1]', 'VARCHAR(90)') AS Paziente_ASL_DescAslAssistenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientAdditionalDemographic/ns0:PatientPrimaryFacility[upper-case((ns2:IdentifierTypeCode)[1]) = ''ASLR'']/ns2:IdNumber)[1]', 'VARCHAR(90)') AS Paziente_ASL_CodAslResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientAdditionalDemographic/ns0:PatientPrimaryFacility[upper-case((ns2:IdentifierTypeCode)[1]) = ''ASLR'']/ns2:OrganizationName)[1]', 'VARCHAR(90)') AS Paziente_ASL_DescAslResidenza

		--PAZIENTE - ALTRO
		,@XmlFile.value('(/ns1:Message/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''LIVCONS'']/ns0:Comment)[1]', 'VARCHAR(MAX)') AS Paziente_Altro_ConsensoFseRegionale

		--PRESCRIZIONE - INFORMAZIONI GENERALI
		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:PlacerGroupNumber/ns2:EntityIdentifier) return <a>{concat(",", $i)}</a>').value('.', 'varchar(22)'), 1, 1, '') as Prescrizione_InformazioniGenerali_Nre
		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:PlacerOrderNumber/ns2:EntityIdentifier) return <a>{concat(",", $i)}</a>').value('.', 'varchar(22)'), 1, 1, '') as Prescrizione_InformazioniGenerali_IdRegionale


		--MODIFICA ETTORE SECONDO INDICAZIONI DI FORACCHIA: fare come è stati fatto per le prescrizioni (prima si restituiva NULL)
		--Eseguo un test usando varchar per vedere se il campo esiste
		,CASE WHEN ISNULL(@XmlFile.value('(/ns1:Message/ns0:Order[ns0:CommonOrder/ns0:OrderControl != ''PA''][1]/ns0:CommonOrder/ns0:DateTimeOfTransaction/ns2:TS_Time)[1]', 'VARCHAR(40)'),'') <> ''  THEN
			@XmlFile.value('(/ns1:Message/ns0:Order[ns0:CommonOrder/ns0:OrderControl != ''PA''][1]/ns0:CommonOrder/ns0:DateTimeOfTransaction/ns2:TS_Time)[1]', 'DATETIME')
		ELSE 
			@XmlFile.value('(/ns1:Message/ns0:Header/ns0:DateTimeOfMessage/ns0:TimeStamp1)[1]', 'DATETIME')
		END AS Prescrizione_InformazioniGenerali_Data

		,@XmlFile.value('(/ns1:Message/ns0:Header/ns0:MessageType/ns0:MessageType)[1]', 'VARCHAR(15)') AS Prescrizione_InformazioniGenerali_TipoPrescrizione

		--MODIFICA ETTORE 2020-07-24: Correzione per lettura del campo "Prescrizione_InformazioniGenerali_Esenzione"
		-- NUOVA LOGICA:
		--	se /ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:FinancialClass/ns2:FinancialClassCode)[1] = 'N' restituisco /ns1:Message/ns0:Patient/ns0:NotesAndComments[ns0:CommentType/ns2:Identifier = ''FasciaReddito'']/ns0:Comment)[1]
		--	altrimenti restituisco /ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:FinancialClass/ns2:FinancialClassCode)[1]
		--
		,@XmlFile.query('if((/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:FinancialClass/ns2:FinancialClassCode)[1] = ''N'') then (
			(/ns1:Message/ns0:Patient/ns0:NotesAndComments[ns0:CommentType/ns2:Identifier = ''FasciaReddito'']/ns0:Comment)[1]
		) else (
			(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:FinancialClass/ns2:FinancialClassCode)[1]
		)' ).value('.', 'VARCHAR(MAX)') AS Prescrizione_InformazioniGenerali_Esenzione

		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:PatientClass)[1]', 'VARCHAR(1)') AS Prescrizione_InformazioniGenerali_CodTipoVisita
		,@XmlFile.value('(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:OrderControlCodeReason/ns2:Identifier)[1]', 'VARCHAR(200)') AS Prescrizione_InformazioniGenerali_CodTipoRicetta
		,@XmlFile.value('(/ns1:Message/ns0:NotesAndComments[ns0:CommentType/ns2:Identifier = ''RicettaInterna'']/ns0:Comment)[1]', 'BIT') AS Prescrizione_InformazioniGenerali_PrescrizioneUsoInterno
		,@XmlFile.value('(/ns1:Message/ns0:Order/ns0:TimingQuantity/ns0:ConditionText)[1]', 'VARCHAR(250)') AS Prescrizione_InformazioniGenerali_CodTipoIndicazione
			
		-- Campo non trovato: DG1.3-CE.1 (Forse si trova dentro PD1.12?)
		,NULL AS Prescrizione_InformazioniGenerali_OscuramentoDatiAnagr

		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:TimingQuantity/ns0:TotalOccurrenceS) return <a>{concat(",", $i)}</a>').value('.', 'varchar(10)'), 1, 1, '') as Prescrizione_InformazioniGenerali_TotaleConfezioniPrestazioni


		-- PRESCRIZIONE - NOTE
	
			,stuff(@XmlFile.query(
		'if(count(/ns1:Message/ns0:Order/ns0:ObservationRequest)[1] > 0) then(
			for $i in distinct-values(/ns1:Message/ns0:Order/ns0:ObservationRequest/ns0:RelevantClinicalInformation) return <a>{concat(",", $i)}</a>
		 )
		 else if(count(/ns1:Message/ns0:Order/ns0:PharmacyTreatmentOrder)[1] > 0) then(
			for $i in distinct-values(/ns1:Message/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''PROPOSTATERAPEUTICA'']/ns0:Comment) return <a>{concat(",", $i)}</a>
		)
		else(
			
		 )'
		).value('.', 'varchar(MAX)'), 1, 1, '') as Prescrizione_Note_PropostaTerapeutica



		,stuff(@XmlFile.query(
		'if(count(/ns1:Message/ns0:Order/ns0:ObservationRequest)[1] > 0) then(
		for $i in distinct-values(/ns1:Message/ns0:Order/ns0:ObservationRequest/ns0:ReasonForStudy/ns2:Identifier) return <a>{concat(",", $i)}</a>
		 )
		 else if(count(/ns1:Message/ns0:Order/ns0:PharmacyTreatmentOrder)[1] > 0) then(
			for $i in distinct-values(ns1:Message/ns0:Order/ns0:PharmacyTreatmentOrder/ns0:Indication[upper-case((ns2:NameOfCodingSystem)[1]) = ''ICD9CM'']/ns2:Identifier) return <a>{concat(",", $i)}</a>
		 )else(
			
		 )'
		).value('.', 'varchar(300)'), 1, 1, '') as Prescrizione_Note_CodQuesitoDiagnostico


		,stuff(@XmlFile.query(
		'if(count(/ns1:Message/ns0:Order/ns0:ObservationRequest)[1] > 0) then(
		for $i in distinct-values(/ns1:Message/ns0:Order/ns0:ObservationRequest/ns0:ReasonForStudy/ns2:Text) return <a>{concat(",", $i)}</a>
		 )
		 else if(count(/ns1:Message/ns0:Order/ns0:PharmacyTreatmentOrder)[1] > 0) then(
			for $i in distinct-values(/ns1:Message/ns0:Order/ns0:PharmacyTreatmentOrder[upper-case((ns0:Indication/ns2:NameOfCodingSystem)[1]) = ''ICD9CM'']/ns0:Indication/ns2:Text) return <a>{concat(",", $i)}</a>
			
		 )else()'
		).value('.', 'varchar(2048)'), 1, 1, '') as Prescrizione_Note_DescQuesitoDiagnostico
		
		
		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:TimingQuantity/ns0:TextInstruction) return <a>{concat(",", $i)}</a>').value('.', 'varchar(250)'), 1, 1, '') as Prescrizione_Note_NoteUsoRegionale

		--PRESCRIZIONE - SPECIALISTICHE
		--MODIFICA ETTORE 2017-06-22: tali campi devono essere popolati solo per le "Specialistiche"
		--ATTENZIONE il campo su Database ora è di 20 caratteri...
		, CASE WHEN @Specialistica > 0 AND @Versione = '' THEN
				--XPATH ORIGINALE: 
				NULLIF(stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:TimingQuantity/ns0:Priority/ns2:Identifier) return <a>{concat(",", $i)}</a>').value('.', 'varchar(20)'), 1, 1, ''),'')
			WHEN @Specialistica > 0 AND @Versione = '0.5' THEN
				--Modify Date: 2019-12-09 ETTORE: nuovo xpath per leggere la priorita
				NULLIF(stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:TimingQuantity/ns0:Priority[2]/ns2:Identifier) return <a>{concat(",", $i)}</a>').value('.', 'varchar(20)'), 1, 1, '') ,'')
			ELSE 
				NULL
			END AS Prescrizione_Specialistiche_Priorita
		, CASE WHEN @Specialistica > 0 THEN
				@XmlFile.value('(/ns1:Message/ns0:Order/ns0:CommonOrder[upper-case((ns0:OrderControl)[1]) = ''PA'']/ns0:PlacerOrderNumber/ns2:EntityIdentifier)[1]', 'VARCHAR(22)')
			ELSE 
				NULL
			END AS Prescrizione_Specialistiche_IdRegionalePrescrizioneRiferimento
		, CASE WHEN @Specialistica > 0 THEN
				@XmlFile.value('(/ns1:Message/ns0:Order/ns0:CommonOrder[upper-case((ns0:OrderControl)[1]) = ''PA'']/ns0:PlacerGroupNumber/ns2:EntityIdentifier)[1]', 'VARCHAR(22)') 
			ELSE 
				NULL
			END AS Prescrizione_Specialistiche_NrePrescrizioneRiferimento		
		, CASE WHEN @Specialistica > 0 THEN
				@XmlFile.value('(/ns1:Message/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''VERSIONESOLE'']/ns0:Comment)[1]', 'VARCHAR(MAX)') 
			ELSE 
				NULL
			END AS Prescrizione_Specialistiche_VersioneCatalogoPrestRegionale
		, CASE WHEN @Specialistica > 0 THEN
				@XmlFile.value('(/ns1:Message/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''PRESCRIZIONESTANDARD'']/ns0:Comment)[1]', 'BIT')
			ELSE 
				NULL
			END AS Prescrizione_Specialistiche_PrestFuoriCatalogoRegionale
	
		--PRESCRIZIONE - ROSSE
		,NULL AS Prescrizione_Rossa_BarCodeCF
		 
		--PRESCRIZIONE - FARMACEUTICHE
		--MODIFICA ETTORE 2017-06-22: tali campi devono essere popolati solo per le "Farmaceutiche"
		, CASE WHEN @Farmaceutica > 0 THEN
				@XmlFile.value('(/ns1:Message/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''VERSIONEPRONTUARIO'']/ns0:Comment)[1]', 'VARCHAR(MAX)')
			ELSE 
				NULL
			END AS Prescrizione_Farmaceutiche_VersioneProntuarioFarmRegionale
		, CASE WHEN @Farmaceutica > 0 THEN
				@XmlFile.value('(/ns1:Message/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''PRESCRIZIONESTANDARD'']/ns0:Comment)[1]', 'BIT')
			ELSE 
				NULL
			END AS Prescrizione_Farmaceutiche_FarmaciSenzaPA

	END
	ELSE -- MESSAGGI CUP2000 - SAR - ROSSA
	BEGIN

		-- Legge i dati dall'allegato
		WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
						, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
						, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
		
		INSERT INTO @Ret
		SELECT
		--INFORMAZIONI TECNICHE
		 NULL AS InformazioniTecniche_Promemoria
		,NULL AS InformazioniTecniche_MacAddressPrescrittore
		,@XmlFile.value('(/ns1:Message/ns0:Header/ns0:SendingApplication/ns2:NamespaceId)[1]', 'VARCHAR(227)') AS InformazioniTecniche_SwPrescrittore

		-- MEDICO TITOLARE
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:AttendingDoctor/ns2:IdNumber)[1]', 'VARCHAR(60)') AS Medico_Titolare_CodiceFiscale
		,NULL AS Medico_Titolare_CodRegionale		
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:AttendingDoctor/ns2:FamilyName/ns2:Surname)[1]', 'VARCHAR(60)') AS Medico_Titolare_Cognome
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:AttendingDoctor/ns2:GivenName)[1]', 'VARCHAR(60)') AS Medico_Titolare_Nome
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:AttendingDoctor/ns2:DegreeEGMd)[1]', 'VARCHAR(60)') AS Medico_Titolare_CodTipoSpecializzazione
		,NULL AS Medico_Titolare_CodRegione
		,NULL AS Medico_Titolare_CodAzienda
		,NULL AS Medico_Titolare_CodStruttura
		,NULL AS Medico_Titolare_Indirizzo
		
		--MEDICO PRESCRITTORE
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) =''CF'']/ns2:IdNumber)[1]', 'VARCHAR(60)') AS Medico_Prescrittore_CodiceFiscale
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) =''CODMAT'']/ns2:IdNumber)[1]', 'VARCHAR(60)') AS Medico_Prescrittore_CodRegionale
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor/ns2:FamilyName/ns2:Surname)[1]', 'VARCHAR(60)') AS Medico_Prescrittore_Cognome
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor/ns2:GivenName)[1]', 'VARCHAR(60)') AS Medico_Prescrittore_Nome
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor/ns2:DegreeEGMd)[1]', 'VARCHAR(60)') AS Medico_Prescrittore_CodTipoSpecializzazione
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) = ''CODMAT'']/ns2:AssigningAuthority/ns2:NamespaceId)[1]', 'VARCHAR(60)')  AS Medico_Prescrittore_CodAzienda
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor[upper-case((ns2:IdentifierTypeCode)[1]) = ''CODMAT'']/ns2:AssigningAuthority/ns2:UniversalId)[1]', 'VARCHAR(60)') AS Medico_Prescrittore_DescAzienda
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:ReferringDoctor/ns2:AssigningFacility/ns2:NamespaceId)[1]', 'VARCHAR(60)')  AS Medico_Prescrittore_Indirizzo

		--PAZIENTE - DOCUMENTI IDENTITA'
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''CF'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_CodiceFiscale
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''CS'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_TesseraSanitaria
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''PNT'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_STP
		,NULL AS Paziente_DocumentiIdentita_ENI
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''NNXXX'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_NumeroIdPersonale
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:AssigningAuthority/ns2:UniversalIdType)[1])=''ISTAT'']/ns2:AssigningAuthority/ns2:NamespaceId)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_CodStatoEstero
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:AssigningAuthority/ns2:UniversalIdType)[1])=''ISTAT'']/ns2:AssigningAuthority/ns2:UniversalId)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_DescStatoEstero
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''HC'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_TsEuropea
		,@XmlFile.value('(/ns1:Message/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''DATASCADTESSERA'']/ns0:Comment)[1]', 'DATE') AS Paziente_DocumentiIdentita_ScandenzaTS
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1]) =''HC'']/ns2:AssigningAuthority/ns2:NamespaceId)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_IstituzioneTS
		,NULL AS Paziente_DocumentiIdentita_TesseraSASN
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:AssigningAuthority/ns2:UniversalIdType)[1])=''AUSLAPPART'']/ns2:AssigningAuthority/ns2:NamespaceId)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_CodAuslAppartenenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:AssigningAuthority/ns2:UniversalIdType)[1])=''AUSLAPPART'']/ns2:AssigningAuthority/ns2:NamespaceId)[1]', 'VARCHAR(20)')  AS Paziente_DocumentiIdentita_DescAuslAppartenenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientIdentifierList[upper-case((ns2:IdentifierTypeCode)[1])=''CIIP'']/ns2:IdNumber)[1]', 'VARCHAR(20)') AS Paziente_DocumentiIdentita_MatricolaCIIP
		,NULL AS Paziente_DocumentiIdentita_CodSocietaNavigazione
		,NULL AS Paziente_DocumentiIdentita_DescSocietaNavigazione

		--PAZIENTE - DATI ANAGRAFICI
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientName/ns2:FamilyName/ns2:Surname)[1]', 'VARCHAR(48)') AS Paziente_DatiAnagrafici_Cognome
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientName/ns2:GivenName)[1]', 'VARCHAR(48)') AS Paziente_DatiAnagrafici_Nome
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:AdministrativeSex)[1]', 'VARCHAR(1)') AS Paziente_DatiAnagrafici_Sesso
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:DateTimeOfBirth/ns2:TS_Time)[1]', 'DATETIME') AS Paziente_DatiAnagrafici_DataNascita
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''BR'']/ns2:CountyParishCode)[1]', 'VARCHAR(106)') AS Paziente_DatiAnagrafici_CodComuneNascita
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''BR'']/ns2:City)[1]', 'VARCHAR(106)') AS Paziente_DatiAnagrafici_DescComuneNascita
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:Citizenship/ns2:Identifier)[1]', 'VARCHAR(80)') AS Paziente_DatiAnagrafici_CodCittadinanza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:Citizenship/ns2:Text)[1]', 'VARCHAR(80)') AS Paziente_DatiAnagrafici_DescCittadinanza


		--PAZIENTE - INDIRIZZI
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:StreetAddress/ns2:StreetOrMailingAddress)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_IndirizzoResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:CountyParishCode)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_CodComuneResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:City)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_DescComuneResidenza
		,NULL AS Paziente_Indirizzi_CodRegioneResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:ZipOrPostalCode)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_CapResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''L'']/ns2:StateOrProvince)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_ProvResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''H'']/ns2:StreetAddress/ns2:StreetOrMailingAddress)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_IndirizzoDomicilio
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''H'']/ns2:CountyParishCode)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_CodComuneDomicilio
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''H'']/ns2:City)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_DescComuneDomicilio
		,NULL AS Paziente_Indirizzi_CodRegioneDomicilio
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PatientAddress[upper-case((ns2:AddressType)[1]) =''H'']/ns2:ZipOrPostalCode)[1]', 'VARCHAR(106)') AS Paziente_Indirizzi_CapDomicilio
		,NULL AS Paziente_Indirizzi_ProvDomicilio
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientIdentification/ns0:PhoneNumberHome/ns2:LocalNumber)[1]', 'VARCHAR(40)') AS Paziente_Indirizzi_Telefono
		,NULL AS Paziente_Indirizzi_Email
		
		--PAZIENTE - ASL
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientAdditionalDemographic/ns0:PatientPrimaryFacility[upper-case((ns2:IdentifierTypeCode)[1]) = ''ASLA'']/ns2:IdNumber)[1]', 'VARCHAR(90)') AS Paziente_ASL_CodAslAssistenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientAdditionalDemographic/ns0:PatientPrimaryFacility[upper-case((ns2:IdentifierTypeCode)[1]) = ''ASLA'']/ns2:OrganizationName)[1]', 'VARCHAR(90)') AS Paziente_ASL_DescAslAssistenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientAdditionalDemographic/ns0:PatientPrimaryFacility[upper-case((ns2:IdentifierTypeCode)[1]) = ''ASLR'']/ns2:IdNumber)[1]', 'VARCHAR(90)') AS Paziente_ASL_CodAslResidenza
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientAdditionalDemographic/ns0:PatientPrimaryFacility[upper-case((ns2:IdentifierTypeCode)[1]) = ''ASLR'']/ns2:OrganizationName)[1]', 'VARCHAR(90)') AS Paziente_ASL_DescAslResidenza

		--PAZIENTE - ALTRO
		,@XmlFile.value('(/ns1:Message/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''PRESENZACONS'']/ns0:Comment)[1]', 'VARCHAR(MAX)') AS Paziente_Altro_ConsensoFseRegionale

		--PRESCRIZIONE - INFORMAZIONI GENERALI
		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:PlacerGroupNumber/ns2:EntityIdentifier) return <a>{concat(",", $i)}</a>').value('.', 'varchar(22)'), 1, 1, '') as Prescrizione_InformazioniGenerali_Nre
		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:PlacerOrderNumber/ns2:EntityIdentifier) return <a>{concat(",", $i)}</a>').value('.', 'varchar(22)'), 1, 1, '') as Prescrizione_InformazioniGenerali_IdRegionale
		
		--MODIFICA ETTORE SECONDO INDICAZIONI DI FORACCHIA: fare come è stati fatto per le prescrizioni: DateTimeOfTransaction non è detto che venga sempre valorizzato
		--Eseguo un test usando varchar per vedere se il campo esiste
		,CASE WHEN ISNULL(@XmlFile.value('(/ns1:Message/ns0:Order[ns0:CommonOrder/ns0:OrderControl != ''PA''][1]/ns0:CommonOrder/ns0:DateTimeOfTransaction/ns2:TS_Time)[1]', 'VARCHAR(40)'),'') <> ''  THEN
			@XmlFile.value('(/ns1:Message/ns0:Order[ns0:CommonOrder/ns0:OrderControl != ''PA''][1]/ns0:CommonOrder/ns0:DateTimeOfTransaction/ns2:TS_Time)[1]', 'DATETIME')
		ELSE 
			@XmlFile.value('(/ns1:Message/ns0:Header/ns0:DateTimeOfMessage/ns0:TimeStamp1)[1]', 'DATETIME')
		END AS Prescrizione_InformazioniGenerali_Data


		,@XmlFile.value('(/ns1:Message/ns0:Header/ns0:MessageType/ns0:MessageType)[1]', 'VARCHAR(15)') AS Prescrizione_InformazioniGenerali_TipoPrescrizione
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:FinancialClass/ns2:FinancialClassCode)[1]', 'VARCHAR(MAX)') AS Prescrizione_InformazioniGenerali_Esenzione
		,@XmlFile.value('(/ns1:Message/ns0:Patient/ns0:PatientVisit/ns0:PatientClass)[1]', 'VARCHAR(1)') AS Prescrizione_InformazioniGenerali_CodTipoVisita
		,@XmlFile.value('(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:OrderControlCodeReason/ns2:Identifier)[1]', 'VARCHAR(200)') AS Prescrizione_InformazioniGenerali_CodTipoRicetta
		,NULL AS Prescrizione_InformazioniGenerali_PrescrizioneUsoInterno
		,@XmlFile.value('(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:QuantityTiming/ns2:Condition)[1]', 'VARCHAR(250)') AS Prescrizione_InformazioniGenerali_CodTipoIndicazione
		,NULL AS Prescrizione_InformazioniGenerali_OscuramentoDatiAnagr
		,NULL AS Prescrizione_InformazioniGenerali_TotaleConfezioniPrestazioni


		-- PRESCRIZIONE - NOTE
		,NULL AS Prescrizione_Note_PropostaTerapeutica

		,stuff(@XmlFile.query(
		'if(count(/ns1:Message/ns0:Order/ns0:ObservationRequest)[1] > 0) then(
			for $i in distinct-values(/ns1:Message/ns0:Order/ns0:ObservationRequest/ns0:ReasonForStudy/ns2:Identifier) return <a>{concat(",", $i)}</a>
		 )
		 else(

		 )'
		).value('.', 'varchar(300)'), 1, 1, '') as Prescrizione_Note_CodQuesitoDiagnostico


		,stuff(@XmlFile.query(
		'if(count(/ns1:Message/ns0:Order/ns0:ObservationRequest)[1] > 0) then(
		for $i in distinct-values(/ns1:Message/ns0:Order/ns0:ObservationRequest/ns0:ReasonForStudy/ns2:Text) return <a>{concat(",", $i)}</a>

		 )else()'
		).value('.', 'varchar(2048)'), 1, 1, '') as Prescrizione_Note_DescQuesitoDiagnostico
		
		,stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:QuantityTiming/ns1:Text) return <a>{concat(",", $i)}</a>').value('.', 'varchar(250)'), 1, 1, '') as Prescrizione_Note_NoteUsoRegionale


		--PRESCRIZIONE - SPECIALISTICHE
		--MODIFICA ETTORE 2017-06-22: tale campo deve essere popolato solo per le specialistiche
		--NON devo testare la versione: per le ROSSE con il n uovo messaggio la priorità si trova nella stessa posizione.
		, CASE WHEN @Specialistica > 0 THEN
				NULLIF(stuff(@XmlFile.query('for $i in distinct-values(/ns1:Message/ns0:Order/ns0:CommonOrder/ns0:QuantityTiming/ns2:Priority) return <a>{concat(",", $i)}</a>').value('.', 'varchar(20)'), 1, 1, ''),'')
			ELSE 
				NULL
		  END AS Prescrizione_Specialistiche_Priorita

		,NULL AS Prescrizione_Specialistiche_IdRegionalePrescrizioneRiferimento
		,NULL AS Prescrizione_Specialistiche_NrePrescrizioneRiferimento
		,NULL AS Prescrizione_Specialistiche_VersioneCatalogoPrestRegionale
		,NULL AS Prescrizione_Specialistiche_PrestFuoriCatalogoRegionale

		--PRESCRIZIONE - ROSSE
		,@XmlFile.value('(/ns1:Message/ns0:NotesAndComments[ns0:CommentType/ns2:Identifier =''BarcodeCF'']/ns0:Comment)[1]', 'BIT') AS Prescrizione_Rossa_BarCodeCF
		 
		--PRESCRIZIONE - FARMACEUTICHE
		,NULL AS Prescrizione_Farmaceutiche_VersioneProntuarioFarmRegionale
		,NULL AS Prescrizione_Farmaceutiche_FarmaciSenzaPA
		
	END
	RETURN
END