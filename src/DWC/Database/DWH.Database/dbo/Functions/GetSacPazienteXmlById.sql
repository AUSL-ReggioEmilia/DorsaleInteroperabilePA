
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: <Create Date, ,>
-- Modify date: 2012-09-19, Ettore: traslo l'idpaziente @id nell'attivo
-- Modify date: 2018-09-14, Sandro: corretto WHERE NOT NULLIF(Attributo.Valore, '') IS NULL
--									Unico INSERT
--
-- Description:	Crea il nodo pazione per il flusso DWH OUT
-- =============================================
CREATE FUNCTION [dbo].[GetSacPazienteXmlById] (@Id uniqueidentifier)  
RETURNS xml AS  
BEGIN 

	DECLARE @Ret xml
	--
	-- Ettore: traslo l'idpaziente @id nell'attivo
	--
	SELECT @Id = dbo.getPazienteAttivoByIdSac(@Id)
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
	FROM [SAC_Pazienti] Anagrafica
	WHERE Anagrafica.Id = @Id
	--
	-- Riempio la lista degli ttributi
	--
	DECLARE @AttributiTable table (Nome varchar(64), Valore sql_variant)
	
	INSERT INTO @AttributiTable (Nome, Valore) VALUES ('Provenienza', CONVERT(SQL_VARIANT, @Provenienza))
													 ,('IdProvenienza', CONVERT(SQL_VARIANT, @IdProvenienza))
													 ,('DataInserimento', CONVERT(SQL_VARIANT, @DataInserimento))
													 ,('DataModifica', CONVERT(SQL_VARIANT, @DataModifica))
													 ,('Occultato', CONVERT(SQL_VARIANT, @Occultato))
													 ,('Disattivato', CONVERT(SQL_VARIANT, @Disattivato))
													 ,('MantenimentoPediatra', CONVERT(SQL_VARIANT, @MantenimentoPediatra))
													 ,('CapoFamiglia', CONVERT(SQL_VARIANT, @CapoFamiglia))
													 ,('Indigenza', CONVERT(SQL_VARIANT, @Indigenza))
													 ,('CodiceTerminazione', CONVERT(SQL_VARIANT, @CodiceTerminazione))
													 ,('DescrizioneTerminazione', CONVERT(SQL_VARIANT, @DescrizioneTerminazione))
													 ,('DistrettoAmm', CONVERT(SQL_VARIANT, @DistrettoAmm))
													 ,('DistrettoTer', CONVERT(SQL_VARIANT, @DistrettoTer))
													 ,('Ambito', CONVERT(SQL_VARIANT, @Ambito))
													 ,('CodiceMedicoDiBase', CONVERT(SQL_VARIANT, @CodiceMedicoDiBase))
													 ,('DataSceltaMedicoDiBase', CONVERT(SQL_VARIANT, @DataSceltaMedicoDiBase))
													 ,('ComuneRecapitoCodice', CONVERT(SQL_VARIANT, @ComuneRecapitoCodice))
													 ,('ComuneRecapitoNome', CONVERT(SQL_VARIANT, @ComuneRecapitoNome))
													 ,('ProvinciaRecapitoCodice', CONVERT(SQL_VARIANT, @ProvinciaRecapitoCodice))
													 ,('ProvinciaRecapitoNome', CONVERT(SQL_VARIANT, @ProvinciaRecapitoNome))
													 ,('IndirizzoRecapito', CONVERT(SQL_VARIANT, @IndirizzoRecapito))
													 ,('LocalitaRecapito', CONVERT(SQL_VARIANT, @LocalitaRecapito))
													 ,('Telefono1', CONVERT(SQL_VARIANT, @Telefono1))
													 ,('Telefono2', CONVERT(SQL_VARIANT, @Telefono2))
													 ,('Telefono3', CONVERT(SQL_VARIANT, @Telefono3))
													 ,('CodiceSTP', CONVERT(SQL_VARIANT, @CodiceSTP))
													 ,('DataInizioSTP', CONVERT(SQL_VARIANT, @DataInizioSTP))
													 ,('DataFineSTP', CONVERT(SQL_VARIANT, @DataFineSTP))
													 ,('MotivoAnnulloSTP', CONVERT(SQL_VARIANT, @MotivoAnnulloSTP))
													 ,('FusioneId', CONVERT(SQL_VARIANT, @FusioneId))
													 ,('FusioneProvenienza', CONVERT(SQL_VARIANT, @FusioneProvenienza))
													 ,('FusioneIdProvenienza', CONVERT(SQL_VARIANT, @FusioneIdProvenienza))
	
	DECLARE @XmlAttributi xml
	SET @XmlAttributi = (
				SELECT	Attributo.Nome, Attributo.Valore
				FROM @AttributiTable Attributo
				WHERE NOT NULLIF(Attributo.Valore, '') IS NULL
				ORDER BY  Attributo.Nome
				FOR XML AUTO
				)

	SET @Ret = (
				SELECT	Anagrafica.Id, Anagrafica.DataModifica AS DataModifica,
						'ASMN' AS AziendaErogante, 'SAC' AS SistemaErogante, CAST(NULL AS VARCHAR(64)) AS RepartoErogante,
						Anagrafica.Cognome, Anagrafica.Nome, Anagrafica.CodiceFiscale, Anagrafica.Tessera AS CodiceSanitario, 
						Anagrafica.DataNascita, Anagrafica.ComuneNascitaNome AS LuogoNascita, Anagrafica.Sesso,
						--
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
						CAST(NULL AS DATETIME) AS DomicilioDataDecorrenza,
						
						-- Usl residenza
						Anagrafica.CodiceAslRes AS UslResidenzaCodice,
						CAST(0 AS INT) AS UslResidenzaPosizioneAssistito,
						Anagrafica.RegioneResCodice AS UslResidenzaRegioneCodice,
						Anagrafica.ComuneAslResCodice AS UslResidenzaComuneCodice,
						
						-- Usl assistenza
						Anagrafica.CodiceAslAss AS UslAssistenzaCodice,
						CAST(0 AS INT) AS UslAssistenzaPosizioneAssistito,
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

