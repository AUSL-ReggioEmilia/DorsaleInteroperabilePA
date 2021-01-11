







-- =============================================
-- Author:		Nostini Alessandro
-- Create date: 2016-10-12
-- Description:	Ritorna i dati letti dall'allegato XML
-- Modify Date: 2017-06-22 ETTORE: gestione dell'uppercase nelle query xpath quando si filtra per un valore
-- Modify Date: 2020-01-30 ETTORE: [ASMN 7240]: Valorizzazione del campo InfoGenerali_TipoAccesso (prima si restituiva sempre NULL)
-- Modify Date: 2020-02-12 ETTORE: [ASMN 7240]: Controllo sui valori del campo InfoGenerali_TipoAccesso: se 0/1 restituisco altrimenti restituisco NULL
-- =============================================
CREATE FUNCTION dbo.GetPrescrizioniHL7Specialistica
(
 @XmlFile AS XML
)
RETURNS @Ret TABLE (
	--SPECIALISTICA - INFO GENERALI
	 InfoGenerali_Progressivo VARCHAR(4)
	,InfoGenerali_Quantità VARCHAR(20) -- ROSSA: VARCHAR(200)
	,InfoGenerali_Note VARCHAR(256)  --ROSSA: VARCHAR(MAX)
	,InfoGenerali_CodBranca VARCHAR(60)
	,InfoGenerali_TipoAccesso VARCHAR(128)
	
	--SPECIALISTICA - CODIFICHE
	,Codifiche_CodDmRegionale VARCHAR(250)
	,Codifiche_CodCatalogoRegionale VARCHAR(200)
	,Codifiche_DescDmRegionale VARCHAR(200)
	,Codifiche_DescCatalogoRegionale VARCHAR(200)
	,Codifiche_CodAziendale VARCHAR(200)
	,Codifiche_DescAziendale VARCHAR(200)

	--SPECIALISTICA - PERCORSI REGIONALI
	,PercorsiRegionali_CodPacchettoRegionale VARCHAR(250)
	,PercorsiRegionali_CodPercorsoRegionale VARCHAR(250)
	,PercorsiRegionali_DescPercorsoRegionale VARCHAR(250)
	,PercorsiRegionali_CodAziendaPercorsoRegionale VARCHAR(250)
	,PercorsiRegionali_CodStrutturaPercorsoRegionale VARCHAR(250)

	--SPECIALISTICA - DM9/15
	,Dm915_Nota VARCHAR(MAX)
	,Dm915_Erog VARCHAR(MAX)
	,Dm915_Appr VARCHAR(MAX)
	--ATTENZIONE: Il campo "DG1.3 - CE1" non è stato trovato
	,Dm915_Pat VARCHAR(128)

)
AS
BEGIN
	-- Legge numero dei CommonOrderCount
	DECLARE @OrderCount INT = 0;
	DECLARE @Versione AS VARCHAR(16) = '';

	WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
						, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
						, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
	SELECT @OrderCount = @XmlFile.value('count(/ns1:Message/ns0:Order)', 'INT')

	--MODIFICA ETTORE 2020-01-30: Gestione della versione del messaggio
	;WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
					, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
					, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
	SELECT @Versione  = @XmlFile.value('(/ns1:Message/ns0:Header/ns0:VersionId/ns2:InternationalVersionId/ns2:Identifier)[1]', 'VARCHAR(16)');
	IF @Versione IS NULL SET @Versione = ''


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
				--SPECIALISTICA - INFO GENERALI
				 @XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:SetIdObr)[1]', 'VARCHAR(4)') AS InfoGenerali_Progressivo
				,@XmlOrder.value('(ns0:Order/ns0:TimingQuantity/ns0:Quantity/ns2:Quantity)[1]', 'VARCHAR(20)') AS InfoGenerali_Quantità
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:PlacerSupplementalServiceInformation/ns2:Text)[1]', 'VARCHAR(256)') AS InfoGenerali_Note
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:PlacerField1)[1]', 'VARCHAR(60)') AS InfoGenerali_CodBranca

				--MODIFICA ETTORE 2020-01-30: testo la versione 
				, CASE WHEN @Versione = '' THEN
						--DEMA: TipoAccesso veniva passato NULL con vecchio messaggio 
						NULL
					WHEN @Versione = '0.5' THEN
						--Modify Date: 2020-01-30 ETTORE: lettura TipoAccesso (viene usato il nodo 1 di Priority)
						@XmlOrder.value('(/ns0:Order/ns0:TimingQuantity/ns0:Priority[1]/ns2:Identifier)[1]', 'VARCHAR(128)')
					ELSE 
						NULL
					END AS InfoGenerali_TipoAccesso

				--SPECIALISTICA - CODIFICHE
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest[upper-case((ns0:PlacerSupplementalServiceInformation/ns2:NameOfCodingSystem)[1]) =''DMR'']/ns0:PlacerSupplementalServiceInformation/ns2:Identifier)[1]', 'VARCHAR(250)') AS Codifiche_CodDmRegionale
				
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier/ns2:Identifier)[1]', 'VARCHAR(200)') AS Codifiche_CodCatalogoRegionale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest[upper-case((ns0:PlacerSupplementalServiceInformation/ns2:NameOfCodingSystem)[1]) =''DMR'']/ns0:UniversalServiceIdentifier/ns2:Text)[1]', 'VARCHAR(200)') AS Codifiche_DescDmRegionale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier/ns2:Text)[1]', 'VARCHAR(200)') AS Codifiche_DescCatalogoRegionale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier/ns2:AlternateIdentifier)[1]', 'VARCHAR(200)') AS Codifiche_CodAziendale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier/ns2:AlternateText)[1]', 'VARCHAR(200)') AS Codifiche_DescAziendale
			
				--SPECIALISTICA - PERCORSI REGIONALI
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest[upper-case((ns0:PlacerSupplementalServiceInformation/ns2:NameOfCodingSystem)[1]) =''CATALOGO UNICO SOLE'']/ns0:PlacerSupplementalServiceInformation/ns2:Identifier)[1]', 'VARCHAR(250)') AS PercorsiRegionali_CodPacchettoRegionale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest[upper-case((ns0:PlacerSupplementalServiceInformation/ns2:NameOfCodingSystem)[1]) =''PERCORSO'']/ns0:PlacerSupplementalServiceInformation/ns2:Identifier)[1]', 'VARCHAR(250)') AS PercorsiRegionali_CodPercorsoRegionale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest[upper-case((ns0:PlacerSupplementalServiceInformation/ns2:NameOfCodingSystem)[1]) =''PERCORSO'']/ns0:PlacerSupplementalServiceInformation/ns2:Text)[1]', 'VARCHAR(250)') AS PercorsiRegionali_DescPercorsoRegionale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest[upper-case((ns0:PlacerSupplementalServiceInformation/ns2:NameOfCodingSystem)[1]) =''AZIENDA PERCORSO'']/ns0:PlacerSupplementalServiceInformation/ns2:Identifier)[1]', 'VARCHAR(250)') AS PercorsiRegionali_CodAziendaPercorsoRegionale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest[upper-case((ns0:PlacerSupplementalServiceInformation/ns2:NameOfCodingSystem)[1]) =''AZIENDA PERCORSO'']/ns0:PlacerSupplementalServiceInformation/ns2:Text)[1]', 'VARCHAR(250)') AS PercorsiRegionali_CodStrutturaPercorsoRegionale
				
				--SPECIALISTICA - DM9/15
				,@XmlOrder.value('(ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) =''NUMERONOTA'']/ns0:Comment)[1]', 'VARCHAR(MAX)') AS Dm915_Nota
				,@XmlOrder.value('(ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) =''CONDEROGABILITA'']/ns0:Comment)[1]', 'VARCHAR(MAX)') AS Dm915_Erog
				,@XmlOrder.value('(ns0:NotesAndComments[upper-case((ns0:CommentType/ns2:Identifier)[1]) =''APPROPRPRESCRITTIVA'']/ns0:Comment)[1]', 'VARCHAR(MAX)') AS Dm915_Appr
				--ATTENZIONE: Il campo "DG1.3 - CE1" non è stato trovato
				,NULL AS Dm915_Pat
				
				-- 
				-- 
			
		END
		ELSE
		BEGIN
				-- Legge i dati dall'allegato
			WITH XMLNAMESPACES ('http://SOLE.BackBone.Schema.Message/Content/Segments' as ns0
							, 'http://SOLE.BackBone.Schema.Message/Content' as ns1
							, 'http://SOLE.BackBone.Schema.Message/Content/DataTypes' as ns2)
			INSERT @Ret
			SELECT
				--SPECIALISTICA - INFO GENERALI
				 NULL AS InfoGenerali_Progressivo
				,@XmlOrder.value('(ns0:Order/ns0:CommonOrder/ns0:QuantityTiming/ns2:Quantity/ns2:Quantity)[1]', 'VARCHAR(20)') AS InfoGenerali_Quantità
				,@XmlOrder.value('(ns0:Order/ns0:NotesAndComments/ns0:Comment)[1]', 'VARCHAR(256)') AS InfoGenerali_Note
				
				,NULL AS InfoGenerali_CodBranca

				--MODIFICA ETTORE 2020-01-30:
				--NON devo testare la versione perchè per le ROSSE l'orchestrazione non la passa
				--Prima per le ROSSE TipoAccesso veniva restituito sempre NULL da questa function.
				--Verifico che il valore restituito sia 0,1 come sarà per il nuovo messaggio altrimenti restituisco NULL come si faceva per la versione precedente della function
				, CASE WHEN @XmlOrder.value('(/ns0:Order/ns0:CommonOrder/ns0:QuantityTiming[1]/ns2:Condition)[1]', 'varchar(128)') IN ('0','1') THEN
					@XmlOrder.value('(/ns0:Order/ns0:CommonOrder/ns0:QuantityTiming[1]/ns2:Condition)[1]', 'varchar(128)') 
				ELSE
					NULL
				END AS InfoGenerali_TipoAccesso

				--SPECIALISTICA - CODIFICHE
				,NULL AS Codifiche_CodDmRegionale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier[upper-case((ns2:NameOfCodingSystem)[1]) =''CATALOGO UNICO SOLE'']/ns2:Identifier)[1]', 'VARCHAR(200)') AS Codifiche_CodCatalogoRegionale
				,NULL AS Codifiche_DescDmRegionale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier[upper-case((ns2:NameOfCodingSystem)[1]) =''CATALOGO UNICO SOLE'']/ns2:Text)[1]', 'VARCHAR(200)') AS Codifiche_DescCatalogoRegionale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier[upper-case((ns2:NameOfCodingSystem)[1]) !=''CATALOGO UNICO SOLE'']/ns2:Identifier)[1]', 'VARCHAR(200)') AS Codifiche_CodAziendale
				,@XmlOrder.value('(ns0:Order/ns0:ObservationRequest/ns0:UniversalServiceIdentifier[upper-case((ns2:NameOfCodingSystem)[1]) !=''CATALOGO UNICO SOLE'']/ns2:Text)[1]', 'VARCHAR(200)') AS Codifiche_DescAziendale
			
				--SPECIALISTICA - PERCORSI REGIONALI
				,NULL AS PercorsiRegionali_CodPacchettoRegionale
				,NULL AS PercorsiRegionali_CodPercorsoRegionale
				,NULL AS PercorsiRegionali_DescPercorsoRegionale
				,NULL AS PercorsiRegionali_CodAziendaPercorsoRegionale
				,NULL AS PercorsiRegionali_CodStrutturaPercorsoRegionale
				
				--SPECIALISTICA - DM9/15
				,NULL AS Dm915_Nota
				,NULL AS Dm915_Erog
				,NULL AS Dm915_Appr
				--ATTENZIONE: Il campo "DG1.3 - CE1" non è stato trovato
				,NULL AS Dm915_Pat
				
		END
		
		SET @OrderIndex = @OrderIndex + 1
	END

	RETURN
END