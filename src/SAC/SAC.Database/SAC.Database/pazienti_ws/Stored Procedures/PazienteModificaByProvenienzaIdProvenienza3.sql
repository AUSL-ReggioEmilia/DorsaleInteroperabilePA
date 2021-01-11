

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-07 (derivata da versione precedente creata il 2019-11-13)
-- Description:	Aggiorna TUTTI i campi della tabella Pazienti cercando per Provenienza + IdProvenienza
--				(anche il campo Attributi)
--				Usa la SP [pazienti_ws].[PazienteModificaBase] cercando per @Id
-- Modify date: 2020-05-07 - ETTORE: @ComuneAslResCodice e @ComuneAslAssCodice non vengono più valorizzati
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazienteModificaByProvenienzaIdProvenienza3]
(
	 @Utente AS varchar(64)
	 ------------------------------------------
	,@Provenienza varchar(16)   -- Provenienza e IdProvenienza pr identificare il record da modificare
	,@IdProvenienza varchar(64) 
	 ------------------------------------------
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
	,@CodiceAslRes varchar(3) 
	,@ComuneDomCodice varchar(6) 
	,@SubComuneDom varchar(64) 
	,@IndirizzoDom varchar(256) 
	,@LocalitaDom varchar(128) 
	,@CapDom varchar(8) 
	,@PosizioneAss tinyint 
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
	,@Attributi XML = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Id UNIQUEIDENTIFIER
	--
	-- Ricavo l'IdPaziente secondo le logiche prima implementate dalla SP PazientiWsDettaglioByIdProveneinza() ora implementate nella funzione
	-- dbo.GetPazienteByProvenienzaIdProvenienza()
	-- Questo @IdPaziente può essere sia attivo che fuso
	-- 
	SELECT @Id = dbo.GetPazienteByProvenienzaIdProvenienza (@Provenienza, @IdProvenienza)
	--Metto a NULL @Provenienza e @IdProvenienza tanto uso @Id per cercare il record
	SET @Provenienza = NULL
	SET @IdProvenienza = NULL

	EXECUTE [pazienti_ws].[PazienteModificaBase3] 
	   @Utente
	  ,@Id
	  ,@Provenienza
	  ,@IdProvenienza
	  ,@Tessera
	  ,@Cognome
	  ,@Nome
	  ,@DataNascita
	  ,@Sesso
	  ,@ComuneNascitaCodice
	  ,@NazionalitaCodice
	  ,@CodiceFiscale
	  ,@MantenimentoPediatra
	  ,@CapoFamiglia
	  ,@Indigenza
	  ,@CodiceTerminazione
	  ,@DescrizioneTerminazione
	  ,@ComuneResCodice
	  ,@SubComuneRes
	  ,@IndirizzoRes
	  ,@LocalitaRes
	  ,@CapRes
	  ,@DataDecorrenzaRes
	  ,@CodiceAslRes
	  ,@ComuneDomCodice
	  ,@SubComuneDom
	  ,@IndirizzoDom
	  ,@LocalitaDom
	  ,@CapDom
	  ,@PosizioneAss
	  ,@CodiceAslAss
	  ,@DataInizioAss
	  ,@DataScadenzaAss
	  ,@DataTerminazioneAss
	  ,@DistrettoAmm
	  ,@DistrettoTer
	  ,@Ambito
	  ,@CodiceMedicoDiBase
	  ,@CodiceFiscaleMedicoDiBase
	  ,@CognomeNomeMedicoDiBase
	  ,@DistrettoMedicoDiBase
	  ,@DataSceltaMedicoDiBase
	  ,@ComuneRecapitoCodice
	  ,@IndirizzoRecapito
	  ,@LocalitaRecapito
	  ,@Telefono1
	  ,@Telefono2
	  ,@Telefono3
	  ,@CodiceSTP
	  ,@DataInizioSTP
	  ,@DataFineSTP
	  ,@MotivoAnnulloSTP
	  ,@RegioneResCodice
	  ,@RegioneAssCodice
	  ,@Attributi
END