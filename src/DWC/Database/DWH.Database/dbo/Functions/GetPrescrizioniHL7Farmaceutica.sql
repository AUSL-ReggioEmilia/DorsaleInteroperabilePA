




-- =============================================
-- Author:		Nostini Alessandro
-- Create date: 2016-10-12
-- Description:	Ritorna i dati letti dall'allegato XML
-- Modify Date: 2017-06-22 ETTORE: Gestione dell'uppercase nelle query xpath quando si filtra per un valore
--								   Per le NON DEMA ricerco il farmaco anche nel percorso delle DEMA 
-- =============================================
CREATE FUNCTION [dbo].[GetPrescrizioniHL7Farmaceutica]
(
 @XmlFile AS XML
)
RETURNS @Ret TABLE (
	 --FARMACEUTICA - INFO GENERALI
	  InfoGenerali_Progressivo VARCHAR(250)
	 ,InfoGenerali_Quantita VARCHAR(20)
	 ,InfoGenerali_Posologia VARCHAR(200)
	 ,InfoGenerali_Note VARCHAR(MAX)
	 ,InfoGenerali_Classe VARCHAR(MAX)
	 ,InfoGenerali_NotaAifa VARCHAR(200)
	 ,InfoGenerali_NonSostituibile BIT
	 ,InfoGenerali_CodMotivazioneNonSostituibile VARCHAR(250)

	 --FARMACEUTICA - CODIFICHE
	 ,Codifiche_AicSpecialita VARCHAR(100)
	 ,Codifiche_MinSan10Specialita VARCHAR(128)
	 ,Codifiche_DescSpecialita VARCHAR(100)
	 ,Codifiche_CodGruppoTerapeutico VARCHAR(250)
	 ,Codifiche_CodGruppoEquivalenza VARCHAR(250)
	 ,Codifiche_DescGruppoEquivalenza VARCHAR(250)
	 ,PercorsiRegionali_CodPercorsoRegionale VARCHAR(250)
	 ,PercorsiRegionali_DescPercorsoRegionale VARCHAR(250)
	 ,PercorsiRegionali_CodAziendaPercorsoRegionale VARCHAR(250)
	 ,PercorsiRegionali_CodStrutturaPercorsoRegionale VARCHAR(250)

)
AS
BEGIN
	-- Legge numero dei CommonOrderCount
	DECLARE @OrderCount INT = 0;

	WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
						, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
						, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
	SELECT @OrderCount = @XmlFile.value('count(/ns1:Message/ns0:Order)', 'INT')

	DECLARE @OrderIndex INT = 1
	WHILE @OrderIndex <= @OrderCount
	BEGIN
		DECLARE @XmlOrder XML = NULL;
		-- Legge i dati dall'allegato
		WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
							, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
							, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
		SELECT @XmlOrder = @XmlFile.query('(/ns1:Message)[1]/ns0:Order[sql:variable("@OrderIndex")]');

		DECLARE @MessageType VARCHAR(128) = NULL;
		WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
						, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
						, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
		SELECT
		@MessageType = @XmlFile.value('(ns1:Message/ns0:Header/ns0:MessageType/ns0:MessageType)[1]', 'VARCHAR(128)');
			

		-- Se @MessageType è OMG,ORG,OMP o ORP allora si tratta di un messaggio DEMA
		IF (@MessageType = 'OMG' OR @MessageType = 'ORG' OR @MessageType='OMP' OR @MessageType = 'ORP')
		BEGIN

			-- Legge i dati dall'allegato
			WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
							, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
							, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
			INSERT @Ret
			SELECT 				
				 --FARMACEUTICA - INFO GENERALI
				 @XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:ProviderSPharmacyTreatmentInstructions/ns2:Text)[1]', 'VARCHAR(250)') AS InfoGenerali_Progressivo
				,@XmlOrder.value('(ns0:Order/ns0:TimingQuantity/ns0:Quantity/ns2:Quantity)[1]', 'VARCHAR(20)') AS InfoGenerali_Quantita
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:ProviderSAdministrationInstructions/ns2:Text)[1]', 'VARCHAR(200)') AS InfoGenerali_Posologia
				,@XmlOrder.value('(ns0:Order/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''NOTE'']/ns0:Comment)[1]', 'VARCHAR(MAX)') AS InfoGenerali_Note
				,NULL AS InfoGenerali_Classe
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:Indication[upper-case((ns2:Text)[1]) =''AIFA'']/ns2:Identifier)[1]', 'VARCHAR(200)') AS InfoGenerali_NotaAifa
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:SupplementaryCode[upper-case((ns2:NameOfCodingSystem)[1]) =''NONSOST'']/ns2:Identifier)[1]', 'BIT') AS InfoGenerali_NonSostituibile
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:SupplementaryCode[upper-case((ns2:NameOfCodingSystem)[1]) =''CODMOTIVAZIONE'']/ns2:AlternateIdentifier)[1]', 'VARCHAR(250)') AS InfoGenerali_CodMotivazioneNonSostituibile
			
				--FARMACEUTICA - CODIFICHE
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:RequestedGiveCode/ns2:Identifier)[1]', 'VARCHAR(100)') AS Codifiche_AicSpecialita
				,NULL AS Codifiche_MinSan10Specialita
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:RequestedGiveCode/ns2:Text)[1]', 'VARCHAR(100)') AS Codifiche_DescSpecialita
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:SupplementaryCode[upper-case((ns2:NameOfCodingSystem)[1]) =''ATC'']/ns2:Identifier)[1]', 'VARCHAR(250)') AS Codifiche_CodGruppoTerapeutico
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:SupplementaryCode[upper-case((ns2:NameOfCodingSystem)[1]) =''GRUPPO EQUIVALENZA'']/ns2:Identifier)[1]', 'VARCHAR(250)') AS Codifiche_CodGruppoEquivalenza
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:SupplementaryCode[upper-case((ns2:NameOfCodingSystem)[1]) =''GRUPPO EQUIVALENZA'']/ns2:Text)[1]', 'VARCHAR(250)') AS Codifiche_DescGruppoEquivalenza

				--FARMACEUTICHE - PERCORSI REGIONALI
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:SupplementaryCode[upper-case((ns2:NameOfCodingSystem)[1]) =''PERCORSO'']/ns2:Identifier)[1]', 'VARCHAR(250)') AS PercorsiRegionali_CodPercorsoRegionale
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:SupplementaryCode[upper-case((ns2:NameOfCodingSystem)[1]) =''PERCORSO'']/ns2:Text)[1]', 'VARCHAR(250)') AS PercorsiRegionali_DescPercorsoRegionale
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:SupplementaryCode[upper-case((ns2:NameOfCodingSystem)[1]) =''AZIENDA PERCORSO'']/ns2:Identifier)[1]', 'VARCHAR(250)') AS PercorsiRegionali_CodAziendaPercorsoRegionale
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:SupplementaryCode[upper-case((ns2:NameOfCodingSystem)[1]) =''AZIENDA PERCORSO'']/ns2:Text)[1]', 'VARCHAR(250)') AS PercorsiRegionali_CodStrutturaPercorsoRegionale
		
		END
		ELSE
		BEGIN
				-- Legge i dati dall'allegato
			WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
							, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
							, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
			INSERT @Ret
			SELECT
				 --FARMACEUTICA - INFO GENERALI
				 NULL AS InfoGenerali_Progressivo
				,@XmlOrder.value('(ns0:Order/ns0:CommonOrder/ns0:QuantityTiming/ns2:Quantity/ns2:Quantity)[1]', 'VARCHAR(20)') AS InfoGenerali_Quantita
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:ProviderSAdministrationInstructions/ns2:Text)[1]', 'VARCHAR(200)') AS InfoGenerali_Posologia
				,@XmlOrder.value('(ns0:Order/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''NOTE'']/ns0:Comment)[1]', 'VARCHAR(MAX)') AS InfoGenerali_Note
				,@XmlOrder.value('(ns0:Order/ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) = ''CLASSE FARMACO'']/ns0:Comment)[1]', 'VARCHAR(MAX)') AS InfoGenerali_Classe
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:Indication/ns2:Identifier)[1]', 'VARCHAR(200)') AS InfoGenerali_NotaAifa
				,NULL AS InfoGenerali_NonSostituibile
				,NULL AS InfoGenerali_CodMotivazioneNonSostituibile
			
				--FARMACEUTICA - CODIFICHE
				,NULL AS Codifiche_AicSpecialita
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:RequestedGiveCode[upper-case((ns2:NameOfCodingSystem)[1]) = ''MINSAN10'']/ns2:Identifier)[1]', 'VARCHAR(100)') AS Codifiche_MinSan10Specialita

				--MODIFICA ETTORE: se non lo trovo qui devo cercare nel percorso delle DEMA
				,CASE WHEN ISNULL(@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:RequestedGiveCode[upper-case((ns2:NameOfCodingSystem)[1]) = ''MINSAN10'']/ns2:Text)[1]', 'VARCHAR(100)'), '') <> '' THEN	
						@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:RequestedGiveCode[upper-case((ns2:NameOfCodingSystem)[1]) = ''MINSAN10'']/ns2:Text)[1]', 'VARCHAR(100)')
					ELSE
						--Eseguo stesa query xpath che si esegue per le DEMA
						@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:RequestedGiveCode/ns2:Text)[1]', 'VARCHAR(100)') 
					END AS Codifiche_DescSpecialita

				,NULL AS Codifiche_CodGruppoTerapeutico
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:RequestedGiveCode[upper-case((ns2:NameOfCodingSystem)[1]) = ''GRUPPO DI EQUIVALENZA'']/ns2:Identifier)[1]', 'VARCHAR(250)') AS Codifiche_CodGruppoEquivalenza
				,@XmlOrder.value('(ns0:Order/ns0:PharmacyTreatmentOrder/ns0:RequestedGiveCode[upper-case((ns2:NameOfCodingSystem)[1]) = ''GRUPPO DI EQUIVALENZA'']/ns2:Text)[1]', 'VARCHAR(250)') AS Codifiche_DescGruppoEquivalenza

				--FARMACEUTICHE - PERCORSI REGIONALI
				,NULL AS PercorsiRegionali_CodPercorsoRegionale
				,NULL AS PercorsiRegionali_DescPercorsoRegionale
				,NULL AS PercorsiRegionali_CodAziendaPercorsoRegionale
				,NULL AS PercorsiRegionali_CodStrutturaPercorsoRegionale
		END
		SET @OrderIndex = @OrderIndex + 1
	END

	RETURN
END