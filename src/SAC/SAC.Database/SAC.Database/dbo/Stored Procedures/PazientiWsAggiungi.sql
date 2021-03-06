﻿
CREATE PROCEDURE [dbo].[PazientiWsAggiungi]
	  @Identity varchar(64)

	, @IdProvenienza varchar(64)
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

AS
BEGIN

DECLARE @Id uniqueidentifier

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiScrittura(@Identity) = 0
	BEGIN
		EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsAggiungi', 'Utente non ha i permessi di scrittura!'

		RAISERROR('Errore di controllo accessi durante PazientiWsAggiungi!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	SET @Id = newid()

	EXEC dbo.PazientiWsBaseInsert @Identity, @Id, @IdProvenienza, @Tessera, @Cognome, @Nome, @DataNascita, @Sesso, 
									@ComuneNascitaCodice, @NazionalitaCodice, @CodiceFiscale, @ComuneResCodice, 
									@SubComuneRes, @IndirizzoRes, @LocalitaRes, @CapRes, @ComuneDomCodice, @SubComuneDom, 
									@IndirizzoDom, @LocalitaDom, @CapDom, @IndirizzoRecapito, @LocalitaRecapito, 
									@Telefono1, @Telefono2, @Telefono3
									


	SELECT @Id AS Id
	
END
 















GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsAggiungi] TO [DataAccessWs]
    AS [dbo];

