-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2017-10-24
-- Modify date: 2018-09-14, Sandro: corretto WHERE NOT NULLIF(Attributo.Valore, '') IS NULL
-- Modify date: 2019-01-22 Refactoring cambio schema
-- Modify date: 2019-02-04 Aggiunti attributi consensi
-- Modify date: 2019-05-05, Sandro: Rimosso correzione WHERE NOT NULLIF(Attributo.Valore, '') IS NULL
--								Primo testo con meno differenze
--
-- Description:	Ritorna il nodo pazinete per flusso SOLE
--				Copiata da [dbo].[[GetSacPazienteXmlForSoleById]]
-- =============================================
CREATE FUNCTION [sole].[OttieneSacPazienteXml]
(
 @IdPaziente uniqueidentifier
)  
RETURNS XML AS  
BEGIN 

	DECLARE @Ret xml
	--
	-- 2012-09-19: traslazione dell'idpaziente nell'attivo
	--
	DECLARE @Id uniqueidentifier = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
	--
	-- Creo nodi Attributi
	--
	DECLARE @Provenienza [varchar](16)
	DECLARE @IdProvenienza [varchar](64)
	DECLARE @DataInserimento [datetime]
	DECLARE @DataModifica [datetime]
	DECLARE @Occultato [bit]
	DECLARE @Disattivato [tinyint]
	DECLARE @ComuneNascitaCodice [varchar](6)
	DECLARE @ComuneNascitaNome [varchar](128)
	DECLARE @ProvinciaNascitaCodice [varchar](3)
	DECLARE @ProvinciaNascitaNome [varchar](2)
	DECLARE @NazionalitaCodice [varchar](3)
	DECLARE @NazionalitaNome [varchar](128)
	DECLARE @MantenimentoPediatra [bit]
	DECLARE @CapoFamiglia [bit]
	DECLARE @Indigenza [bit]
	DECLARE @CodiceTerminazione [varchar](8)
	DECLARE @DescrizioneTerminazione [varchar](64)
	DECLARE @ComuneResCodice [varchar](6)
	DECLARE @ComuneResNome [varchar](128)
	DECLARE @ProvinciaResCodice [varchar](3)
	DECLARE @ProvinciaResNome [varchar](2)
	DECLARE @SubComuneRes [varchar](64)
	DECLARE @IndirizzoRes [varchar](256)
	DECLARE @LocalitaRes [varchar](128)
	DECLARE @CapRes [varchar](8)
	DECLARE @DataDecorrenzaRes [datetime]
	DECLARE @ProvinciaAslResCodice [varchar](3)
	DECLARE @ProvinciaAslResNome [varchar](2)
	DECLARE @ComuneAslResCodice [varchar](6)
	DECLARE @AslResNome [varchar](128)
	DECLARE @CodiceAslRes [varchar](3)
	DECLARE @RegioneResCodice [varchar](3)
	DECLARE @RegioneResNome [varchar](128)
	DECLARE @ComuneDomCodice [varchar](6)
	DECLARE @ComuneDomNome [varchar](128)
	DECLARE @ProvinciaDomCodice [varchar](3)
	DECLARE @ProvinciaDomNome [varchar](2)
	DECLARE @SubComuneDom [varchar](64)
	DECLARE @IndirizzoDom [varchar](256)
	DECLARE @LocalitaDom [varchar](128)
	DECLARE @CapDom [varchar](8)
	DECLARE @PosizioneAss [tinyint]
	DECLARE @RegioneAssCodice [varchar](3)
	DECLARE @RegioneAssNome [varchar](128)
	DECLARE @ProvinciaAslAssCodice [varchar](3)
	DECLARE @ProvinciaAslAssNome [varchar](2)
	DECLARE @ComuneAslAssCodice [varchar](6)
	DECLARE @AslAssNome [varchar](128)
	DECLARE @CodiceAslAss [varchar](3)
	DECLARE @DataInizioAss [datetime]
	DECLARE @DataScadenzaAss [datetime]
	DECLARE @DataTerminazioneAss [datetime]
	DECLARE @DistrettoAmm [varchar](8)
	DECLARE @DistrettoTer [varchar](16)
	DECLARE @Ambito [varchar](16)
	DECLARE @CodiceMedicoDiBase [int]
	DECLARE @CodiceFiscaleMedicoDiBase [varchar](16)
	DECLARE @CognomeNomeMedicoDiBase [varchar](128)
	DECLARE @DistrettoMedicoDiBase [varchar](8)
	DECLARE @DataSceltaMedicoDiBase [datetime]
	DECLARE @ComuneRecapitoCodice [varchar](6)
	DECLARE @ComuneRecapitoNome [varchar](128)
	DECLARE @ProvinciaRecapitoCodice [varchar](3)
	DECLARE @ProvinciaRecapitoNome [varchar](2)
	DECLARE @IndirizzoRecapito [varchar](256)
	DECLARE @LocalitaRecapito [varchar](128)
	DECLARE @Telefono1 [varchar](20)
	DECLARE @Telefono2 [varchar](20)
	DECLARE @Telefono3 [varchar](20)
	DECLARE @CodiceSTP [varchar](32)
	DECLARE @DataInizioSTP [datetime]
	DECLARE @DataFineSTP [datetime]
	DECLARE @MotivoAnnulloSTP [varchar](8)
	DECLARE @FusioneId [uniqueidentifier]
	DECLARE @FusioneProvenienza [varchar](16)
	DECLARE @FusioneIdProvenienza [varchar](64)

	-- 2019-02-04
	--
	DECLARE @DataDecesso [DateTime]
	DECLARE @ConsensoAziendaleCodice [int]
	DECLARE @ConsensoAziendaleDescrizione [varchar](64)
	DECLARE @ConsensoAziendaleData [DateTime]
	DECLARE @ConsensoSoleCodice [int]
	DECLARE @ConsensoSoleDescrizione [varchar](64)
	DECLARE @ConsensoSoleData [DateTime]
	DECLARE @LivelloAttendibilita [int]
	
	SELECT	@Provenienza = Provenienza
		,@IdProvenienza = IdProvenienza
		,@DataInserimento = DataInserimento
		,@DataModifica = DataModifica
		,@Occultato = Occultato
		,@Disattivato = Disattivato
		,@ComuneNascitaCodice = ComuneNascitaCodice
		,@ComuneNascitaNome = ComuneNascitaNome
		,@ProvinciaNascitaCodice = ProvinciaNascitaCodice
		,@ProvinciaNascitaNome = ProvinciaNascitaNome
		,@NazionalitaCodice = NazionalitaCodice
		,@NazionalitaNome = NazionalitaNome
		,@MantenimentoPediatra = MantenimentoPediatra
		,@CapoFamiglia = CapoFamiglia
		,@Indigenza = Indigenza
		,@CodiceTerminazione = CodiceTerminazione
		,@DescrizioneTerminazione = DescrizioneTerminazione
		,@ComuneResCodice = ComuneResCodice
		,@ComuneResNome = ComuneResNome
		,@ProvinciaResCodice = ProvinciaResCodice
		,@ProvinciaResNome = ProvinciaResNome
		,@SubComuneRes = SubComuneRes
		,@IndirizzoRes = IndirizzoRes
		,@LocalitaRes = LocalitaRes
		,@CapRes = CapRes
		,@DataDecorrenzaRes = DataDecorrenzaRes
		,@ProvinciaAslResCodice = ProvinciaAslResCodice
		,@ProvinciaAslResNome = ProvinciaAslResNome
		,@ComuneAslResCodice = ComuneAslResCodice
		,@AslResNome = AslResNome
		,@CodiceAslRes = CodiceAslRes
		,@RegioneResCodice = RegioneResCodice
		,@RegioneResNome = RegioneResNome
		,@ComuneDomCodice = ComuneDomCodice
		,@ComuneDomNome = ComuneDomNome
		,@ProvinciaDomCodice = ProvinciaDomCodice
		,@ProvinciaDomNome = ProvinciaDomNome
		,@SubComuneDom = SubComuneDom
		,@IndirizzoDom = IndirizzoDom
		,@LocalitaDom = LocalitaDom
		,@CapDom = CapDom
		,@PosizioneAss = PosizioneAss
		,@RegioneAssCodice = RegioneAssCodice
		,@RegioneAssNome = RegioneAssNome
		,@ProvinciaAslAssCodice = ProvinciaAslAssCodice
		,@ProvinciaAslAssNome = ProvinciaAslAssNome
		,@ComuneAslAssCodice = ComuneAslAssCodice
		,@AslAssNome = AslAssNome
		,@CodiceAslAss = CodiceAslAss
		,@DataInizioAss = DataInizioAss
		,@DataScadenzaAss = DataScadenzaAss
		,@DataTerminazioneAss = DataTerminazioneAss
		,@DistrettoAmm = DistrettoAmm
		,@DistrettoTer = DistrettoTer
		,@Ambito = Ambito
		,@CodiceMedicoDiBase = CodiceMedicoDiBase
		,@CodiceFiscaleMedicoDiBase = CodiceFiscaleMedicoDiBase
		,@CognomeNomeMedicoDiBase = CognomeNomeMedicoDiBase
		,@DistrettoMedicoDiBase = DistrettoMedicoDiBase
		,@DataSceltaMedicoDiBase = DataSceltaMedicoDiBase
		,@ComuneRecapitoCodice = ComuneRecapitoCodice
		,@ComuneRecapitoNome = ComuneRecapitoNome
		,@ProvinciaRecapitoCodice = ProvinciaRecapitoCodice
		,@ProvinciaRecapitoNome = ProvinciaRecapitoNome
		,@IndirizzoRecapito = IndirizzoRecapito
		,@LocalitaRecapito = LocalitaRecapito
		,@Telefono1 = Telefono1
		,@Telefono2 = Telefono2
		,@Telefono3 = Telefono3
		,@CodiceSTP = CodiceSTP
		,@DataInizioSTP = DataInizioSTP
		,@DataFineSTP = DataFineSTP
		,@MotivoAnnulloSTP = MotivoAnnulloSTP
		,@FusioneId = FusioneId
		,@FusioneProvenienza = FusioneProvenienza
		,@FusioneIdProvenienza = FusioneIdProvenienza

		-- 2019-02-04
		--
		,@DataDecesso = [DataDecesso]
		,@ConsensoAziendaleCodice = [ConsensoAziendaleCodice]
		,@ConsensoAziendaleDescrizione = [ConsensoAziendaleDescrizione]
		,@ConsensoAziendaleData = [ConsensoAziendaleData]
		,@ConsensoSoleCodice = [ConsensoSoleCodice]
		,@ConsensoSoleDescrizione = [ConsensoSoleDescrizione]
		,@ConsensoSoleData = [ConsensoSoleData]
		,@LivelloAttendibilita = [LivelloAttendibilita]

	FROM [SAC_Pazienti] Anagrafica
	WHERE Anagrafica.Id = @Id
		
	DECLARE @AttributiTable TABLE (Nome VARCHAR(64), Valore SQL_VARIANT)
	
	INSERT INTO @AttributiTable (Nome, Valore) VALUES ('Provenienza', CONVERT(SQL_VARIANT, @Provenienza))
													, ('IdProvenienza', CONVERT(SQL_VARIANT, @IdProvenienza))
													, ('DataInserimento', CONVERT(SQL_VARIANT, @DataInserimento))
													, ('DataModifica', CONVERT(SQL_VARIANT, @DataModifica))
													, ('Occultato', CONVERT(SQL_VARIANT, @Occultato))
													, ('Disattivato', CONVERT(SQL_VARIANT, @Disattivato))
													, ('ComuneNascitaCodice', CONVERT(SQL_VARIANT, @ComuneNascitaCodice))
													, ('ComuneNascitaNome', CONVERT(SQL_VARIANT, @ComuneNascitaNome))
													, ('ProvinciaNascitaCodice', CONVERT(SQL_VARIANT, @ProvinciaNascitaCodice))
													, ('ProvinciaNascitaNome', CONVERT(SQL_VARIANT, @ProvinciaNascitaNome))
													, ('NazionalitaCodice', CONVERT(SQL_VARIANT, @NazionalitaCodice))
													, ('NazionalitaNome', CONVERT(SQL_VARIANT, @NazionalitaNome))
													, ('MantenimentoPediatra', CONVERT(SQL_VARIANT, @MantenimentoPediatra))
													, ('CapoFamiglia', CONVERT(SQL_VARIANT, @CapoFamiglia))
													, ('Indigenza', CONVERT(SQL_VARIANT, @Indigenza))
													, ('CodiceTerminazione', CONVERT(SQL_VARIANT, @CodiceTerminazione))
													, ('DescrizioneTerminazione', CONVERT(SQL_VARIANT, @DescrizioneTerminazione))
													, ('ComuneResCodice', CONVERT(SQL_VARIANT, @ComuneResCodice))
													, ('ComuneResNome', CONVERT(SQL_VARIANT, @ComuneResNome))
													, ('ProvinciaResCodice', CONVERT(SQL_VARIANT, @ProvinciaResCodice))
													, ('ProvinciaResNome', CONVERT(SQL_VARIANT, @ProvinciaResNome))
													, ('SubComuneRes', CONVERT(SQL_VARIANT, @SubComuneRes))
													, ('IndirizzoRes', CONVERT(SQL_VARIANT, @IndirizzoRes))
													, ('LocalitaRes', CONVERT(SQL_VARIANT, @LocalitaRes))
													, ('CapRes', CONVERT(SQL_VARIANT, @CapRes))
													, ('DataDecorrenzaRes', CONVERT(SQL_VARIANT, @DataDecorrenzaRes))
													, ('ProvinciaAslResCodice', CONVERT(SQL_VARIANT, @ProvinciaAslResCodice))
													, ('ProvinciaAslResNome', CONVERT(SQL_VARIANT, @ProvinciaAslResNome))
													, ('ComuneAslResCodice', CONVERT(SQL_VARIANT, @ComuneAslResCodice))
													, ('AslResNome', CONVERT(SQL_VARIANT, @AslResNome))
													, ('CodiceAslRes', CONVERT(SQL_VARIANT, @CodiceAslRes))
													, ('RegioneResCodice', CONVERT(SQL_VARIANT, @RegioneResCodice))
													, ('RegioneResNome', CONVERT(SQL_VARIANT, @RegioneResNome))
													, ('ComuneDomCodice', CONVERT(SQL_VARIANT, @ComuneDomCodice))
													, ('ComuneDomNome', CONVERT(SQL_VARIANT, @ComuneDomNome))
													, ('ProvinciaDomCodice', CONVERT(SQL_VARIANT, @ProvinciaDomCodice))
													, ('ProvinciaDomNome', CONVERT(SQL_VARIANT, @ProvinciaDomNome))
													, ('SubComuneDom', CONVERT(SQL_VARIANT, @SubComuneDom))
													, ('IndirizzoDom', CONVERT(SQL_VARIANT, @IndirizzoDom))
													, ('LocalitaDom', CONVERT(SQL_VARIANT, @LocalitaDom))
													, ('CapDom', CONVERT(SQL_VARIANT, @CapDom))
													, ('PosizioneAss', CONVERT(SQL_VARIANT, @PosizioneAss))
													, ('RegioneAssCodice', CONVERT(SQL_VARIANT, @RegioneAssCodice))
													, ('RegioneAssNome', CONVERT(SQL_VARIANT, @RegioneAssNome))
													, ('ProvinciaAslAssCodice', CONVERT(SQL_VARIANT, @ProvinciaAslAssCodice))
													, ('ProvinciaAslAssNome', CONVERT(SQL_VARIANT, @ProvinciaAslAssNome))
													, ('ComuneAslAssCodice', CONVERT(SQL_VARIANT, @ComuneAslAssCodice))
													, ('AslAssNome', CONVERT(SQL_VARIANT, @AslAssNome))
													, ('CodiceAslAss', CONVERT(SQL_VARIANT, @CodiceAslAss))
													, ('DataInizioAss', CONVERT(SQL_VARIANT, @DataInizioAss))
													, ('DataScadenzaAss', CONVERT(SQL_VARIANT, @DataScadenzaAss))
													, ('DataTerminazioneAss', CONVERT(SQL_VARIANT, @DataTerminazioneAss))
													, ('DistrettoAmm', CONVERT(SQL_VARIANT, @DistrettoAmm))
													, ('DistrettoTer', CONVERT(SQL_VARIANT, @DistrettoTer))
													, ('Ambito', CONVERT(SQL_VARIANT, @Ambito))
													, ('CodiceMedicoDiBase', CONVERT(SQL_VARIANT, @CodiceMedicoDiBase))
													, ('CodiceFiscaleMedicoDiBase', CONVERT(SQL_VARIANT, @CodiceFiscaleMedicoDiBase))
													, ('CognomeNomeMedicoDiBase', CONVERT(SQL_VARIANT, @CognomeNomeMedicoDiBase))
													, ('DistrettoMedicoDiBase', CONVERT(SQL_VARIANT, @DistrettoMedicoDiBase))
													, ('DataSceltaMedicoDiBase', CONVERT(SQL_VARIANT, @DataSceltaMedicoDiBase))
													, ('ComuneRecapitoCodice', CONVERT(SQL_VARIANT, @ComuneRecapitoCodice))
													, ('ComuneRecapitoNome', CONVERT(SQL_VARIANT, @ComuneRecapitoNome))
													, ('ProvinciaRecapitoCodice', CONVERT(SQL_VARIANT, @ProvinciaRecapitoCodice))
													, ('ProvinciaRecapitoNome', CONVERT(SQL_VARIANT, @ProvinciaRecapitoNome))
													, ('IndirizzoRecapito', CONVERT(SQL_VARIANT, @IndirizzoRecapito))
													, ('LocalitaRecapito', CONVERT(SQL_VARIANT, @LocalitaRecapito))
													, ('Telefono1', CONVERT(SQL_VARIANT, @Telefono1))
													, ('Telefono2', CONVERT(SQL_VARIANT, @Telefono2))
													, ('Telefono3', CONVERT(SQL_VARIANT, @Telefono3))
													, ('CodiceSTP', CONVERT(SQL_VARIANT, @CodiceSTP))
													, ('DataInizioSTP', CONVERT(SQL_VARIANT, @DataInizioSTP))
													, ('DataFineSTP', CONVERT(SQL_VARIANT, @DataFineSTP))
													, ('MotivoAnnulloSTP', CONVERT(SQL_VARIANT, @MotivoAnnulloSTP))
													, ('FusioneId', CONVERT(SQL_VARIANT, @FusioneId))
													, ('FusioneProvenienza', CONVERT(SQL_VARIANT, @FusioneProvenienza))
													, ('FusioneIdProvenienza', CONVERT(SQL_VARIANT, @FusioneIdProvenienza))

		-- 2019-02-04
		--
													, ('DataDecesso', CONVERT(SQL_VARIANT, @DataDecesso))
													, ('ConsensoAziendaleCodice', CONVERT(SQL_VARIANT, @ConsensoAziendaleCodice))
													, ('ConsensoAziendaleDescrizione', CONVERT(SQL_VARIANT, @ConsensoAziendaleDescrizione))
													, ('ConsensoAziendaleData', CONVERT(SQL_VARIANT, @ConsensoAziendaleData))
													, ('ConsensoSoleCodice', CONVERT(SQL_VARIANT, @ConsensoSoleCodice))
													, ('ConsensoSoleDescrizione', CONVERT(SQL_VARIANT, @ConsensoSoleDescrizione))
													, ('ConsensoSoleData', CONVERT(SQL_VARIANT, @ConsensoSoleData))
													, ('LivelloAttendibilita', CONVERT(SQL_VARIANT, @LivelloAttendibilita))
	
	DECLARE @XmlAttributi xml
	SET @XmlAttributi = (
				SELECT	Attributo.Nome, Attributo.Valore
				FROM @AttributiTable Attributo

				--Prevista la modifica ma ritardate per fare un primo test con meno differenze
				--WHERE NOT NULLIF(Attributo.Valore, '') IS NULL

				WHERE NOT Attributo.Valore IS NULL
				ORDER BY  Attributo.Nome
				FOR XML AUTO
				)

	SET @Ret = (
				SELECT	Anagrafica.Id, Anagrafica.DataModifica AS DataModifica,
						'ASMN' AS AziendaErogante, 'SAC' AS SistemaErogante, CONVERT(VARCHAR(64), NULL) AS RepartoErogante,
						Anagrafica.Cognome, Anagrafica.Nome, Anagrafica.CodiceFiscale, Anagrafica.Tessera AS CodiceSanitario, 
						Anagrafica.DataNascita, Anagrafica.ComuneNascitaNome AS LuogoNascita, Anagrafica.Sesso,

						--NUOVI Elemnents per allinearlo a quello per errore usato negli eventi
						Anagrafica.ComuneNascitaCodice AS ComuneNascitaCodice,
						Anagrafica.NazionalitaCodice AS NazionalitaCodice,
						Anagrafica.NazionalitaNome AS NazionalitaNome,
						
						-- Residenza
						Anagrafica.ComuneResCodice AS ResidenzaComuneCodice,
						Anagrafica.ComuneResNome AS ResidenzaComuneNome,
						Anagrafica.IndirizzoRes AS ResidenzaIndirizzo,
						Anagrafica.LocalitaRes AS ResidenzaLocalita,
						Anagrafica.CAPRes AS ResidenzaCAP,
						Anagrafica.DataDecorrenzaRes AS ResidenzaDataDecorrenza,
						
						-- Domicilio
						Anagrafica.ComuneDomCodice AS DomicilioComuneCodice,
						Anagrafica.ComuneDomNome AS DomicilioComuneNome,
						Anagrafica.IndirizzoDom AS DomicilioIndirizzo,
						Anagrafica.LocalitaDom AS DomicilioLocalita,
						Anagrafica.CAPDom AS DomicilioCAP,
						
						-- Usl residenza
						Anagrafica.CodiceAslRes AS UslResidenzaCodice,
						Anagrafica.RegioneResCodice AS UslResidenzaRegioneCodice,
						Anagrafica.ComuneAslResCodice AS UslResidenzaComuneCodice,
						
						-- Usl assistenza
						Anagrafica.CodiceAslAss AS UslAssistenzaCodice,
						Anagrafica.RegioneAssCodice AS UslAssistenzaRegioneCodice,
						Anagrafica.ComuneAslAssCodice AS UslAssistenzaComuneCodice,
						
						--Medico di base
						Anagrafica.CodiceFiscaleMedicoDiBase AS MedicoDiBaseCodiceFiscale,
						Anagrafica.CognomeNomeMedicoDiBase AS MedicoDiBaseCognomeNome,
						Anagrafica.DistrettoMedicoDiBase AS MedicoDiBaseDistretto,	

						@XmlAttributi AS Attributi

				FROM [SAC_Pazienti] Anagrafica
				WHERE ID = @ID
				FOR XML AUTO, ELEMENTS
				)

	RETURN @Ret

END