
-- =============================================
-- Author:		Ettore
-- Create date: 2015-09-14
-- Description:	Aggiorna TUTTI i campi della tabella Pazienti cercando per IdSac
-- =============================================
CREATE PROCEDURE [dbo].[PazientiWsModifica3ById]
(
	  @Identity varchar(64)

	, @Id uniqueidentifier	--Id SAC dell'anagrafica
	, @Provenienza varchar(16) --La provenienza che verrà testata per capire se si può aggiornare

	,@Tessera varchar(16) 
	,@Cognome varchar(64) 
	,@Nome varchar(64) 
	,@DataNascita datetime 
	,@Sesso varchar(1) 
	,@ComuneNascitaCodice varchar(6) 
	,@NazionalitaCodice varchar(3) 
	,@CodiceFiscale varchar(16) 
	,@MantenimentoPediatra bit 
	,@CapoFamiglia bit 
	,@Indigenza bit 
	,@CodiceTerminazione varchar(8) 
	,@DescrizioneTerminazione varchar(64) 
	,@ComuneResCodice varchar(6) 
	,@SubComuneRes varchar(64) 
	,@IndirizzoRes varchar(256) 
	,@LocalitaRes varchar(128) 
	,@CapRes varchar(8) 
	,@DataDecorrenzaRes datetime 
	,@ComuneAslResCodice varchar(6) 
	,@CodiceAslRes varchar(3) 
	,@ComuneDomCodice varchar(6) 
	,@SubComuneDom varchar(64) 
	,@IndirizzoDom varchar(256) 
	,@LocalitaDom varchar(128) 
	,@CapDom varchar(8) 
	,@PosizioneAss tinyint 
	,@ComuneAslAssCodice varchar(6) 
	,@CodiceAslAss varchar(3) 
	,@DataInizioAss datetime 
	,@DataScadenzaAss datetime 
	,@DataTerminazioneAss datetime 
	,@DistrettoAmm varchar(8) 
	,@DistrettoTer varchar(16) 
	,@Ambito varchar(16) 
	,@CodiceMedicoDiBase int 
	,@CodiceFiscaleMedicoDiBase varchar(16) 
	,@CognomeNomeMedicoDiBase varchar(128) 
	,@DistrettoMedicoDiBase varchar(8) 
	,@DataSceltaMedicoDiBase datetime 
	,@ComuneRecapitoCodice varchar(6) 
	,@IndirizzoRecapito varchar(256) 
	,@LocalitaRecapito varchar(128) 
	,@Telefono1 varchar(20) 
	,@Telefono2 varchar(20) 
	,@Telefono3 varchar(20) 
	,@CodiceSTP varchar(32) 
	,@DataInizioSTP datetime 
	,@DataFineSTP datetime 
	,@MotivoAnnulloSTP varchar(8) 
	,@RegioneResCodice varchar(3) 
	,@RegioneAssCodice varchar(3)
)
AS
BEGIN

DECLARE @IdProvenienza varchar(64)
SET @IdProvenienza = NULL

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiScrittura(@Identity) = 0
	BEGIN
		EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsModifica3ById', 'Utente non ha i permessi di scrittura!'

		RAISERROR('Errore di controllo accessi durante PazientiWsModifica3ById!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	-- Aggiornamento record
	---------------------------------------------------
	EXEC dbo.PazientiWsBaseUpdate3 
						@Identity, @Id , @Provenienza , @IdProvenienza 
						, @Tessera ,@Cognome ,@Nome ,@DataNascita ,@Sesso 
						, @ComuneNascitaCodice ,@NazionalitaCodice ,@CodiceFiscale ,@MantenimentoPediatra ,@CapoFamiglia ,@Indigenza 
						, @CodiceTerminazione ,@DescrizioneTerminazione 
						, @ComuneResCodice ,@SubComuneRes ,@IndirizzoRes ,@LocalitaRes ,@CapRes ,@DataDecorrenzaRes 
						, @ComuneAslResCodice ,@CodiceAslRes
						, @ComuneDomCodice ,@SubComuneDom, @IndirizzoDom ,@LocalitaDom, @CapDom 
						, @PosizioneAss 
						, @ComuneAslAssCodice ,@CodiceAslAss ,@DataInizioAss ,@DataScadenzaAss ,@DataTerminazioneAss 
						, @DistrettoAmm , @DistrettoTer ,@Ambito 
						, @CodiceMedicoDiBase ,@CodiceFiscaleMedicoDiBase , @CognomeNomeMedicoDiBase ,@DistrettoMedicoDiBase
						, @DataSceltaMedicoDiBase
						, @ComuneRecapitoCodice ,@IndirizzoRecapito, @LocalitaRecapito, @Telefono1 ,@Telefono2, @Telefono3
						, @CodiceSTP, @DataInizioSTP, @DataFineSTP, @MotivoAnnulloSTP
						, @RegioneResCodice 
						, @RegioneAssCodice 
									
	---------------------------------------------------
	-- Return
	---------------------------------------------------
	SELECT Id 
	FROM PazientiAttiviResult
	WHERE ID = @Id
	
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsModifica3ById] TO [DataAccessWs]
    AS [dbo];

