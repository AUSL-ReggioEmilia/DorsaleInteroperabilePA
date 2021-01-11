

-- Ritorna un segmento XML di tutto l'Evento
--
--Nuovo	 2015-11-13 - Sandro - Copiata da	[GetEventoXml]
-- Modify date: 2016-08-10 Sandro: Tabella split data e attributi senza campo XML
--									Usa tabella PrescrizioneBase
-- Modify date: 2016-11-16 Sandro: Aggiunti campi dati ESTESI
--
CREATE FUNCTION [dbo].[GetPrescrizioneXml]
(
 @Id uniqueidentifier
)
RETURNS XML
AS  
BEGIN 
/*
 Ritorna un segmento XML di tutto l'Evento
	namespace = http://schemas.progel.it/SQL/Dwh/QueuePrescrizioneOutput/1.0
*/
DECLARE @XmlAnagrafica xml
DECLARE @XmlEvento xml
		
	IF NOT @ID IS NULL
	BEGIN
		--
		-- Allegati
		--
		DECLARE @XmlAllegati xml
		SET @XmlAllegati = (
							SELECT Allegato.ID
								, Allegato.IdEsterno
								, Allegato.DataInserimento
								, Allegato.DataModifica
								, Allegato.TipoContenuto
								, dbo.decompress(Allegato.ContenutoCompresso) AS Contenuto
								, CONVERT(XML, (
									SELECT Attributo.Nome, Attributo.Valore
									FROM store.PrescrizioniAllegatiAttributi AS Attributo
									WHERE Attributo.IdPrescrizioniAllegatiBase = Allegato.Id
										AND Attributo.DataPartizione = Allegato.DataPartizione
									ORDER BY  Attributo.Nome
									FOR XML AUTO
									)) AS Attributi

							FROM store.PrescrizioniAllegatiBase AS Allegato
							WHERE Allegato.IdPrescrizioniBase = @ID
							ORDER BY  Allegato.IdEsterno
							FOR XML AUTO, ELEMENTS, BINARY BASE64
							)


		--
		-- Prescrizioni attributi
		--
		DECLARE @XmlAttributiPrescrizioni xml
		SET @XmlAttributiPrescrizioni = (			
			CONVERT(XML, (
							SELECT Attributo.Nome, Attributo.Valore
							FROM store.PrescrizioniAttributi AS Attributo INNER JOIN store.PrescrizioniBase AS Prescrizione
										ON Attributo.IdPrescrizioniBase = Prescrizione.Id
										AND (Attributo.DataPartizione = Prescrizione.DataPartizione)
							WHERE Prescrizione.ID = @Id
							ORDER BY Nome --Questo order by sembra inutile...
							FOR XML AUTO
				)) 
		)

		--
		-- Prescrizioni testata
		--
		DECLARE @XmlPrescrizioniTestata xml
		SET @XmlPrescrizioniTestata = (			
			CONVERT(XML, (
							SELECT InformazioniTecniche_Promemoria, InformazioniTecniche_MacAddressPrescrittore
								, InformazioniTecniche_SwPrescrittore, Medico_Titolare_CodiceFiscale, Medico_Titolare_CodRegionale
								, Medico_Titolare_Cognome, Medico_Titolare_Nome, Medico_Titolare_CodTipoSpecializzazione
								, Medico_Titolare_CodRegione, Medico_Titolare_CodAzienda, Medico_Titolare_CodStruttura
								, Medico_Titolare_Indirizzo, Medico_Prescrittore_CodiceFiscale, Medico_Prescrittore_CodRegionale
								, Medico_Prescrittore_Cognome, Medico_Prescrittore_Nome, Medico_Prescrittore_CodTipoSpecializzazione
								, Medico_Prescrittore_CodAzienda, Medico_Prescrittore_DescAzienda, Medico_Prescrittore_Indirizzo
								, Paziente_DocumentiIdentita_CodiceFiscale, Paziente_DocumentiIdentita_TesseraSanitaria
								, Paziente_DocumentiIdentita_STP, Paziente_DocumentiIdentita_ENI
								, Paziente_DocumentiIdentita_NumeroIdPersonale, Paziente_DocumentiIdentita_CodStatoEstero
								, Paziente_DocumentiIdentita_DescStatoEstero, Paziente_DocumentiIdentita_TsEuropea
								, Paziente_DocumentiIdentita_ScandenzaTS, Paziente_DocumentiIdentita_IstituzioneTS
								, Paziente_DocumentiIdentita_TesseraSASN, Paziente_DocumentiIdentita_CodAuslAppartenenza
								, Paziente_DocumentiIdentita_DescAuslAppartenenza, Paziente_DocumentiIdentita_MatricolaCIIP
								, Paziente_DocumentiIdentita_CodSocietaNavigazione, Paziente_DocumentiIdentita_DescSocietaNavigazione
								, Paziente_DatiAnagrafici_Cognome, Paziente_DatiAnagrafici_Nome, Paziente_DatiAnagrafici_Sesso
								, Paziente_DatiAnagrafici_DataNascita, Paziente_DatiAnagrafici_CodComuneNascita
								, Paziente_DatiAnagrafici_DescComuneNascita, Paziente_DatiAnagrafici_CodCittadinanza
								, Paziente_DatiAnagrafici_DescCittadinanza, Paziente_Indirizzi_IndirizzoResidenza
								, Paziente_Indirizzi_CodComuneResidenza, Paziente_Indirizzi_DescComuneResidenza
								, Paziente_Indirizzi_CodRegioneResidenza, Paziente_Indirizzi_CapResidenza, Paziente_Indirizzi_ProvResidenza
								, Paziente_Indirizzi_IndirizzoDomicilio, Paziente_Indirizzi_CodComuneDomicilio, Paziente_Indirizzi_DescComuneDomicilio
								, Paziente_Indirizzi_CodRegioneDomicilio, Paziente_Indirizzi_CapDomicilio, Paziente_Indirizzi_ProvDomicilio
								, Paziente_Indirizzi_Telefono, Paziente_Indirizzi_Email, Paziente_ASL_CodAslAssistenza
								, Paziente_ASL_DescAslAssistenza, Paziente_ASL_CodAslResidenza, Paziente_ASL_DescAslResidenza
								, Paziente_Altro_ConsensoFseRegionale, Prescrizione_InformazioniGenerali_Nre, Prescrizione_InformazioniGenerali_IdRegionale
								, Prescrizione_InformazioniGenerali_Data, Prescrizione_InformazioniGenerali_TipoPrescrizione
								, Prescrizione_InformazioniGenerali_Esenzione, Prescrizione_InformazioniGenerali_CodTipoVisita
								, Prescrizione_InformazioniGenerali_CodTipoRicetta, Prescrizione_InformazioniGenerali_PrescrizioneUsoInterno
								, Prescrizione_InformazioniGenerali_CodTipoIndicazione, Prescrizione_InformazioniGenerali_OscuramentoDatiAnagr
								, Prescrizione_InformazioniGenerali_TotaleConfezioniPrestazioni, Prescrizione_Note_PropostaTerapeutica
								, Prescrizione_Note_CodQuesitoDiagnostico, Prescrizione_Note_DescQuesitoDiagnostico
								, Prescrizione_Note_NoteUsoRegionale, Prescrizione_Specialistiche_Priorita
								, Prescrizione_Specialistiche_IdRegionalePrescrizioneRiferimento, Prescrizione_Specialistiche_NrePrescrizioneRiferimento
								, Prescrizione_Specialistiche_VersioneCatalogoPrestRegionale, Prescrizione_Specialistiche_PrestFuoriCatalogoRegionale
								, Prescrizione_Rossa_BarCodeCF, Prescrizione_Farmaceutiche_VersioneProntuarioFarmRegionale
								, Prescrizione_Farmaceutiche_FarmaciSenzaPA

							FROM store.PrescrizioniEstesaTestata AS Testata INNER JOIN store.PrescrizioniBase AS Prescrizione
										ON Testata.IdPrescrizioniBase = Prescrizione.Id
										AND Testata.DataPartizione = Prescrizione.DataPartizione
							WHERE Prescrizione.ID = @Id
							FOR XML AUTO, ELEMENTS
				)) 
		)

		--
		-- Prescrizioni Farmaceutica
		--
		DECLARE @XmlPrescrizioniFarmaceutica xml
		SET @XmlPrescrizioniFarmaceutica = (			
			CONVERT(XML, (
							SELECT InfoGenerali_Progressivo, InfoGenerali_Quantita, InfoGenerali_Posologia
								, InfoGenerali_Note, InfoGenerali_Classe, InfoGenerali_NotaAifa, InfoGenerali_NonSostituibile
								, InfoGenerali_CodMotivazioneNonSostituibile, Codifiche_AicSpecialita, Codifiche_MinSan10Specialita
								, Codifiche_DescSpecialita, Codifiche_CodGruppoTerapeutico, Codifiche_CodGruppoEquivalenza
								, Codifiche_DescGruppoEquivalenza, PercorsiRegionali_CodPercorsoRegionale
								, PercorsiRegionali_DescPercorsoRegionale, PercorsiRegionali_CodAziendaPercorsoRegionale
								, PercorsiRegionali_CodStrutturaPercorsoRegionale

							FROM store.PrescrizioniEstesaFarmaceutica AS Farmaceutica INNER JOIN store.PrescrizioniBase AS Prescrizione
										ON Farmaceutica.IdPrescrizioniBase = Prescrizione.Id
										AND Farmaceutica.DataPartizione = Prescrizione.DataPartizione
							WHERE Prescrizione.ID = @Id
							FOR XML AUTO, ELEMENTS
				)) 
		)

		--
		-- Prescrizioni Farmaceutica
		--
		DECLARE @XmlPrescrizioniSpecialistica xml
		SET @XmlPrescrizioniSpecialistica = (			
			CONVERT(XML, (
							SELECT InfoGenerali_Progressivo, InfoGenerali_Quantita, InfoGenerali_Note
								, InfoGenerali_CodBranca, InfoGenerali_TipoAccesso
								, Codifiche_CodDmRegionale, Codifiche_CodCatalogoRegionale, Codifiche_DescDmRegionale
								, Codifiche_DescCatalogoRegionale, Codifiche_CodAziendale, Codifiche_DescAziendale
								, PercorsiRegionali_CodPacchettoRegionale, PercorsiRegionali_CodPercorsoRegionale
								, PercorsiRegionali_DescPercorsoRegionale, PercorsiRegionali_CodAziendaPercorsoRegionale
								, PercorsiRegionali_CodStrutturaPercorsoRegionale, Dm915_Nota, Dm915_Erog, Dm915_Appr, Dm915_Pat

							FROM store.PrescrizioniEstesaSpecialistica AS Specialistica INNER JOIN store.PrescrizioniBase AS Prescrizione
										ON Specialistica.IdPrescrizioniBase = Prescrizione.Id
										AND Specialistica.DataPartizione = Prescrizione.DataPartizione
							WHERE Prescrizione.ID = @Id
							FOR XML AUTO, ELEMENTS
				)) 
		)
		--
		-- Prescrizioni
		--
		;WITH XMLNAMESPACES ('http://schemas.progel.it/SQL/Dwh/QueuePrescrizioneOutput/1.0' as ns0)
		SELECT @XmlEvento = (
			SELECT 	"ns0:Prescrizione".Id
					,dbo.GetPazienteAttivoByIdSac("ns0:Prescrizione".IdPaziente) AS IdPaziente

				-- Ricavo CodiceAnagraficaCentrale e NomeAnagraficaCentrale
				,Attributi.value('(/Attributi/Attributo[@Nome="CodiceAnagraficaCentrale"]/@Valore)[1]', 'varchar(64)') AS CodiceAnagraficaCentrale
				,Attributi.value('(/Attributi/Attributo[@Nome="NomeAnagraficaCentrale"]/@Valore)[1]', 'varchar(64)') AS NomeAnagraficaCentrale

				-- Ricavo paziente da SAC
				,dbo.GetSacPazienteXmlById(dbo.GetPazienteAttivoByIdSac("ns0:Prescrizione".IdPaziente)) AS Paziente		

				, "ns0:Prescrizione".IdEsterno
				, "ns0:Prescrizione".DataInserimento
				, "ns0:Prescrizione".DataModifica
				, "ns0:Prescrizione".DataModificaEsterno
				, "ns0:Prescrizione".StatoCodice
				, "ns0:Prescrizione".TipoPrescrizione
				, "ns0:Prescrizione".DataPrescrizione
				, "ns0:Prescrizione".NumeroPrescrizione
				, "ns0:Prescrizione".MedicoPrescrittoreCodiceFiscale
				, "ns0:Prescrizione".QuesitoDiagnostico
				, "ns0:Prescrizione".PropostaTerapeutica
				, "ns0:Prescrizione".Prestazioni
				, "ns0:Prescrizione".Farmaci

				, @XmlAttributiPrescrizioni AS Attributi
				, @XmlAllegati AS Allegati
				, @XmlPrescrizioniTestata AS EstesaTestata
				, @XmlPrescrizioniFarmaceutica AS EstesaFarmaceutiche
				, @XmlPrescrizioniSpecialistica AS EstesaSpecialistiche

			FROM store.Prescrizioni AS "ns0:Prescrizione"
			WHERE "ns0:Prescrizione".Id = @ID
			FOR XML AUTO, ELEMENTS
				)
	END

	RETURN @XmlEvento
END