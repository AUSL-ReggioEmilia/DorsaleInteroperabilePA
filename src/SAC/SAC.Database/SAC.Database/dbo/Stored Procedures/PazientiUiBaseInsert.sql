
-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date:	2016-07-22 ETTORE: Eseguo il replace di caratteri non desiderati (CHAR(10), CHAR(13)) con ''
-- Description:	SP di inserimento paziente usata da UI
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiBaseInsert]
	  @Tessera varchar(16)
	, @Cognome varchar(64)
	, @Nome varchar(64)
	, @DataNascita datetime
	, @Sesso varchar(1)
	, @ComuneNascitaCodice varchar(6)
	, @NazionalitaCodice varchar(3)
	, @CodiceFiscale varchar(16)
	
	, @DatiAnamnestici varchar(8000)
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

	, @ComuneAslResCodice varchar(6)
	, @CodiceAslRes varchar(3)
	, @RegioneResCodice varchar(3)
	
	, @ComuneDomCodice varchar(6)
	, @SubComuneDom varchar(64)
	, @IndirizzoDom varchar(256)
	, @LocalitaDom varchar(128)
	, @CapDom varchar(8)
	
	, @PosizioneAss tinyint
	, @RegioneAssCodice varchar(3)

	, @ComuneAslAssCodice varchar(6)
	, @CodiceAslAss varchar(3)
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
	, @IndirizzoRecapito varchar(256)
	, @LocalitaRecapito varchar(128)
	, @Telefono1 varchar(20)
	, @Telefono2 varchar(20)
	, @Telefono3 varchar(20)
	, @CodiceSTP varchar(32)
	
	, @DataInizioSTP datetime
	, @DataFineSTP datetime
	, @MotivoAnnulloSTP varchar(8)

	, @Utente AS varchar(64)
AS
BEGIN

DECLARE @DataInserimento AS datetime
DECLARE @Id AS uniqueidentifier

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo Codice Ficale
	---------------------------------------------------
	IF LEN(ISNULL(@CodiceFiscale, '')) = 0
	BEGIN
		RAISERROR('Errore durante PazientiUiBaseInsert, il campo CodiceFiscale è vuoto!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	--
	-- MODIFICA ETTORE 2016-07-22:
	-- Eseguo il replace di caratteri non desiderati (CHAR(10), CHAR(13)) con ''
	--
	SET @Tessera = dbo.ReplaceInvalidChar(@Tessera,'') 
	SET @Cognome = dbo.ReplaceInvalidChar(@Cognome, '') 
	SET @Nome = dbo.ReplaceInvalidChar(@Nome, '') 
	SET @CodiceFiscale = dbo.ReplaceInvalidChar(@CodiceFiscale, '') 
	SET @SubComuneRes = dbo.ReplaceInvalidChar(@SubComuneRes, '') 
	SET @IndirizzoRes = dbo.ReplaceInvalidChar(@IndirizzoRes, '') 
	SET @LocalitaRes = dbo.ReplaceInvalidChar(@LocalitaRes, '') 
	SET @SubComuneDom = dbo.ReplaceInvalidChar(@SubComuneDom, '') 
	SET @IndirizzoDom = dbo.ReplaceInvalidChar(@IndirizzoDom, '') 
	SET @LocalitaDom = dbo.ReplaceInvalidChar(@LocalitaDom, '') 
	SET @CognomeNomeMedicoDiBase = dbo.ReplaceInvalidChar(@CognomeNomeMedicoDiBase, '') 
	SET @IndirizzoRecapito = dbo.ReplaceInvalidChar(@IndirizzoRecapito, '') 
	SET @LocalitaRecapito = dbo.ReplaceInvalidChar(@LocalitaRecapito, '') 
	SET @Telefono1 = dbo.ReplaceInvalidChar(@Telefono1, '') 
	SET @Telefono2 = dbo.ReplaceInvalidChar(@Telefono2, '') 
	SET @Telefono3 = dbo.ReplaceInvalidChar(@Telefono3, '') 

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	SET @DataInserimento = GetDate()
	SET @Id = NewId()
	
	INSERT INTO Pazienti
		( Id
		, Provenienza
		, IdProvenienza
		, DataInserimento
		, DataModifica
		, DataSequenza
		, LivelloAttendibilita
		
		, Tessera
		, Cognome
		, Nome
		, DataNascita
		, Sesso
		, ComuneNascitaCodice
		, NazionalitaCodice
		, CodiceFiscale

		, DatiAnamnestici
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

		, ComuneAslResCodice
		, CodiceAslRes
		, RegioneResCodice

		, ComuneDomCodice
		, SubComuneDom
		, IndirizzoDom
		, LocalitaDom
		, CapDom

		, PosizioneAss
		, RegioneAssCodice
		, ComuneAslAssCodice
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
		, MotivoAnnulloSTP)
	VALUES
		( @Id
		, dbo.ConfigPazientiProvenienzaUi()
		, @Id				--IdProvenienza
		, @DataInserimento
		, @DataInserimento	--DataModifica
		, @DataInserimento	--DataSequenza
		, dbo.ConfigPazientiLivelloAttendibilitaUi()
		
		, @Tessera
		, @Cognome
		, @Nome
		, @DataNascita
		, @Sesso
		, @ComuneNascitaCodice
		, @NazionalitaCodice
		, @CodiceFiscale

		, CONVERT(varbinary(max), @DatiAnamnestici)
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
		, @ComuneAslResCodice
		, @CodiceAslRes
		, @RegioneResCodice

		, @ComuneDomCodice
		, @SubComuneDom
		, @IndirizzoDom
		, @LocalitaDom
		, @CapDom

		, @PosizioneAss
		, @RegioneAssCodice
		, @ComuneAslAssCodice
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
		, @MotivoAnnulloSTP)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec PazientiNotificheAdd @Id, '1', @Utente
	
	---------------------------------------------------
	-- Completato
	--  Ritorna i dati inseriti
	---------------------------------------------------

	COMMIT
	
	SELECT *
	FROM PazientiUiBaseResult
	WHERE Id = @Id
	
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	RETURN 1

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiBaseInsert] TO [DataAccessWs]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiBaseInsert] TO [DataAccessUi]
    AS [dbo];

