





-- =============================================
-- Author:		ETTORE
-- Create date: 2019-11-25
-- Description:	Aggiorna UN SOTTOINSIEME di campi della tabella Pazienti per Id
--				ETTORE: Riattivazione anagrafiche cancellate logicamente [ASMN-4052]
--				Chiama la pazienti_ws.[azienteSemplificatoModificaBase]
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazienteSemplificatoModificaById2]
(
	  @Utente AS varchar(64)
	------------------------------------
	, @Id uniqueidentifier
	------------------------------------
	, @Tessera varchar(16)
	, @Cognome varchar(64)
	, @Nome varchar(64)
	, @DataNascita datetime
	, @Sesso varchar(1)
	, @ComuneNascitaCodice varchar(6)
	, @NazionalitaCodice varchar(3)
	, @CodiceFiscale varchar(16)	
	, @ComuneResCodice varchar(6)
	, @SubComuneRes varchar(64)
	, @IndirizzoRes varchar(256)
	, @LocalitaRes varchar(128)
	, @CapRes varchar(8)
	, @ComuneDomCodice varchar(6)
	, @SubComuneDom varchar(64)
	, @IndirizzoDom varchar(256)
	, @LocalitaDom varchar(128)
	, @CapDom varchar(8)	
	, @IndirizzoRecapito varchar(256)
	, @LocalitaRecapito varchar(128)
	, @Telefono1 varchar(20)
	, @Telefono2 varchar(20)
	, @Telefono3 varchar(20)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- Impoisto a NULL questi parametri che non sono utilizzati
	--
	DECLARE @Provenienza varchar(16) = NULL
	DECLARE @IdProvenienza varchar(64) = NULL
	--
	-- 
	--
	EXECUTE pazienti_ws.PazienteSemplificatoModificaBase
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
	  ,@ComuneResCodice
	  ,@SubComuneRes
	  ,@IndirizzoRes
	  ,@LocalitaRes
	  ,@CapRes
	  ,@ComuneDomCodice
	  ,@SubComuneDom
	  ,@IndirizzoDom
	  ,@LocalitaDom
	  ,@CapDom
	  ,@IndirizzoRecapito
	  ,@LocalitaRecapito
	  ,@Telefono1
	  ,@Telefono2
	  ,@Telefono3

END