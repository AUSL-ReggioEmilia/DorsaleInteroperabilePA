
CREATE PROCEDURE [dbo].[PazientiQueueAdd]
	  @Operazione AS tinyint
	, @Id AS varchar(64)
		
	, @Tessera varchar(16)
	, @Cognome varchar(64)
	, @Nome varchar(64)
	, @DataNascita datetime
	, @Sesso varchar(1)
	, @ComuneNascitaCodice varchar(6)
	, @NazionalitaCodice varchar(3)
	, @CodiceFiscale varchar(16)
	
	, @DatiAnagmestici varchar(8000)
	, @MantenimentoPediatra bit
	, @CapoFamiglia bit
	, @Indigenza bit
	, @CodiceTerminazione varchar(8)
	, @DescrizioneTerminazione varchar(64)
	
	, @ComuneResCodice varchar(6)
	, @SubComuneRes varchar(64)
	, @IndirizzoRes varchar(256)
	, @LocalitaRes varchar(128)
	, @CapRes varchar(8)
	, @DataDecorrenzaRes datetime
	, @CodiceAslRes int
	, @RegioneResCodice varchar(3)
	
	, @ComuneDomCodice varchar(6)
	, @SubComuneDom varchar(64)
	, @IndirizzoDom varchar(256)
	, @LocalitaDom varchar(128)
	, @CapDom varchar(8)
	
	, @PosizioneAss tinyint
	, @RegioneAssCodice varchar(3)
	, @CodiceAslAss varchar(2)
	, @DataInizioAss datetime
	, @DataScadenzaAss datetime
	, @DataTerminazioneAss datetime
	, @DistrettoAmm varchar(8)
	, @DistrettoTer varchar(16)
	, @Ambito varchar(16)
	
	, @CodiceMedicoDiBase int
	, @CodiceFiscaleMedicoDiBase varchar(16)
	, @CognomeNomeMedicoDiBase varchar(128)
	, @DistrettoMedicoDiBase varchar(8)
	, @DataSceltaMedicoDiBase datetime
	
	, @ComuneRecapitoCodice varchar(6)
	, @IndirizzoRecapito varchar(64)
	, @LocalitaRecapito varchar(64)
	, @Telefono1 varchar(20)
	, @Telefono2 varchar(20)
	, @Telefono3 varchar(20)
	, @CodiceSTP varchar(32)
	
	, @DataInizioSTP datetime
	, @DataFineSTP datetime
	, @MotivoAnnulloSTP varchar(8)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO PazientiQueue
		( Operazione
		, Id

		, Tessera
		, Cognome
		, Nome
		, DataNascita
		, Sesso
		, ComuneNascitaCodice
		, NazionalitaCodice
		, CodiceFiscale

		, DatiAnagmestici
		, MantenimentoPediatra
		, CapoFamiglia
		, Indigenza
		, CodiceTerminazione
		, DescrizioneTerminazione

		, ComuneResCodice
		, SubComuneRes
		, IndirizzoRes
		, LocalitaRes
		, CapRes
		, DataDecorrenzaRes
		, CodiceAslRes
		, RegioneResCodice

		, ComuneDomCodice
		, SubComuneDom
		, IndirizzoDom
		, LocalitaDom
		, CapDom

		, PosizioneAss
		, RegioneAssCodice
		, CodiceAslAss
		, DataInizioAss
		, DataScadenzaAss
		, DataTerminazioneAss
		, DistrettoAmm
		, DistrettoTer
		, Ambito

		, CodiceMedicoDiBase
		, CodiceFiscaleMedicoDiBase
		, CognomeNomeMedicoDiBase
		, DistrettoMedicoDiBase
		, DataSceltaMedicoDiBase

		, ComuneRecapitoCodice
		, IndirizzoRecapito
		, LocalitaRecapito
		, Telefono1
		, Telefono2
		, Telefono3
		, CodiceSTP

		, DataInizioSTP
		, DataFineSTP
		, MotivoAnnulloSTP
		)
	VALUES
		( @Operazione
		, @Id

		, @Tessera
		, @Cognome
		, @Nome
		, @DataNascita
		, @Sesso
		, @ComuneNascitaCodice
		, @NazionalitaCodice
		, @CodiceFiscale
		
		, @DatiAnagmestici
		, @MantenimentoPediatra
		, @CapoFamiglia
		, @Indigenza
		, @CodiceTerminazione
		, @DescrizioneTerminazione
		
		, @ComuneResCodice
		, @SubComuneRes
		, @IndirizzoRes
		, @LocalitaRes
		, @CapRes
		, @DataDecorrenzaRes
		, @CodiceAslRes
		, @RegioneResCodice
		
		, @ComuneDomCodice
		, @SubComuneDom
		, @IndirizzoDom
		, @LocalitaDom
		, @CapDom
		
		, @PosizioneAss
		, @RegioneAssCodice
		, @CodiceAslAss
		, @DataInizioAss
		, @DataScadenzaAss
		, @DataTerminazioneAss
		, @DistrettoAmm
		, @DistrettoTer
		, @Ambito
		
		, @CodiceMedicoDiBase
		, @CodiceFiscaleMedicoDiBase
		, @CognomeNomeMedicoDiBase
		, @DistrettoMedicoDiBase
		, @DataSceltaMedicoDiBase
		
		, @ComuneRecapitoCodice
		, @IndirizzoRecapito
		, @LocalitaRecapito
		, @Telefono1
		, @Telefono2
		, @Telefono3
		, @CodiceSTP
		
		, @DataInizioSTP
		, @DataFineSTP
		, @MotivoAnnulloSTP
		)

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiQueueAdd] TO [DataAccessSql]
    AS [dbo];

