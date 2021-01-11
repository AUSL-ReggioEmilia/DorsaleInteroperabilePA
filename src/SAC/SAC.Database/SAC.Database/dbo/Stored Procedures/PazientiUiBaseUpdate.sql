
-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date:	2016-07-22 ETTORE: Eseguo il replace di caratteri non desiderati (CHAR(10), CHAR(13)) con ''
-- Description:	SP di aggiornamento paziente usata da UI
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiBaseUpdate]
	  @Id AS uniqueidentifier
	, @Ts AS timestamp
	
	, @Tessera varchar(16)
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

DECLARE @LivelloAttendibilita AS tinyint
DECLARE @LivelloAttendibilitaCorrente AS tinyint

	SET NOCOUNT ON;
	
	---------------------------------------------------
	-- Controlla livello attendibilita; Aggirna solo se pari o maggiore
	---------------------------------------------------
	
	SELECT @LivelloAttendibilitaCorrente = LivelloAttendibilita
	FROM Pazienti
	WHERE Id = @Id
	
	SET @LivelloAttendibilita = dbo.ConfigPazientiLivelloAttendibilitaUi()
	
	IF @LivelloAttendibilita < @LivelloAttendibilitaCorrente
		BEGIN
			RAISERROR('Errore sul controllo del Livello di Attendibilita!', 16, 1)
			RETURN 1001
		END

	---------------------------------------------------
	-- Controllo Codice Ficale
	---------------------------------------------------
	IF LEN(ISNULL(@CodiceFiscale, '')) = 0
	BEGIN
		RAISERROR('Errore durante PazientiUiBaseUpdate, il campo CodiceFiscale è vuoto!', 16, 1)
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
	-- Aggiorna i dati con il controllo della concorrenza (TS)
	---------------------------------------------------

	UPDATE Pazienti
	SET DataModifica = GetDate()
		, DataSequenza = GetDate()
		, LivelloAttendibilita = @LivelloAttendibilita
		
		, Tessera = @Tessera
		, Cognome = @Cognome
		, Nome = @Nome
		, DataNascita = @DataNascita
		, Sesso = @Sesso
		, ComuneNascitaCodice = @ComuneNascitaCodice
		, NazionalitaCodice = @NazionalitaCodice
		, CodiceFiscale = @CodiceFiscale

		, DatiAnamnestici = CONVERT(varbinary(max), @DatiAnamnestici)
		, MantenimentoPediatra = @MantenimentoPediatra
		, CapoFamiglia = @CapoFamiglia
		, Indigenza = @Indigenza
		, CodiceTerminazione = @CodiceTerminazione
		, DescrizioneTerminazione = @DescrizioneTerminazione

		, ComuneResCodice = @ComuneResCodice
		, SubComuneRes = @SubComuneRes
		, IndirizzoRes = @IndirizzoRes
		, LocalitaRes = @LocalitaRes
		, CapRes = @CapRes
		, DataDecorrenzaRes = @DataDecorrenzaRes
		, ComuneAslResCodice = @ComuneAslResCodice
		, CodiceAslRes = @CodiceAslRes
		, RegioneResCodice = @RegioneResCodice

		, ComuneDomCodice = @ComuneDomCodice
		, SubComuneDom = @SubComuneDom
		, IndirizzoDom = @IndirizzoDom
		, LocalitaDom = @LocalitaDom
		, CapDom = @CapDom

		, PosizioneAss = @PosizioneAss
		, RegioneAssCodice = @RegioneAssCodice
		, ComuneAslAssCodice = @ComuneAslAssCodice
		, CodiceAslAss = @CodiceAslAss
		, DataInizioAss = @DataInizioAss
		, DataScadenzaAss = @DataScadenzaAss
		, DataTerminazioneAss = @DataTerminazioneAss
		, DistrettoAmm = @DistrettoAmm
		, DistrettoTer = @DistrettoTer
		, Ambito = @Ambito

		, CodiceMedicoDiBase = @CodiceMedicoDiBase
		, CodiceFiscaleMedicoDiBase = @CodiceFiscaleMedicoDiBase
		, CognomeNomeMedicoDiBase = @CognomeNomeMedicoDiBase
		, DistrettoMedicoDiBase = @DistrettoMedicoDiBase
		, DataSceltaMedicoDiBase = @DataSceltaMedicoDiBase

		, ComuneRecapitoCodice = @ComuneRecapitoCodice
		, IndirizzoRecapito = @IndirizzoRecapito
		, LocalitaRecapito = @LocalitaRecapito
		, Telefono1 = @Telefono1
		, Telefono2 = @Telefono2
		, Telefono3 = @Telefono3

		, CodiceSTP = @CodiceSTP
		, DataInizioSTP = @DataInizioSTP
		, DataFineSTP = @DataFineSTP
		, MotivoAnnulloSTP = @MotivoAnnulloSTP
		
	WHERE Id = @Id AND Ts = @Ts

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec PazientiNotificheAdd @Id, '1', @Utente

	---------------------------------------------------
	-- Completato
	--  Ritorna i dati aggiornati
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
    ON OBJECT::[dbo].[PazientiUiBaseUpdate] TO [DataAccessUi]
    AS [dbo];

