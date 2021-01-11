﻿
-- =============================================
-- Data modifica: 29/09/2011
-- Descrizione	: commentato il parametro @Identity e Provenienza
--
-- ATTENZIONE: E' stata creata una nuova function 'dbo.GetErroreIncoerenzaIstat()' da usare al posto dei test sui vari comuni.
--		E' stata usata solo nella SP PazientiOutputCercaAggancioPaziente per risolvere problema NESTED EXEC INSERT 
--		quando richiamata dalle manteinance di aggancio del DWH nel caso di creazione del record paziente. 
--		FAREMO LA MODIFICA ALLA PRIMA OCCASIONE ANCHE IN QUESTA SP
--
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputModificaById]
(
	  --@Identity varchar(64)
	  @Id uniqueidentifier
	--, @Provenienza varchar(16)
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
/*
	MODIFICA ETTORE 2014-04-25: 
		1) Normalizzazione dei codici istat dei comuni
		2) Gestione dell'incoerenza istat dei comuni. Se codici istat dei comuni sono incoerenti genero una eccezione 
*/
	DECLARE @Identity AS varchar(64)
	DECLARE @Provenienza varchar(16)
	DECLARE @IdProvenienza varchar(64)
	SET @IdProvenienza = NULL

	SET NOCOUNT ON;

	-- Controllo accesso
	SET @Identity = USER_NAME()

	IF dbo.LeggePazientiPermessiScrittura(@Identity) = 0
	BEGIN
		EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, 'PazientiOutputModificaById', 'Utente non ha i permessi di scrittura!'
		RAISERROR('Errore di controllo accessi durante PazientiOutputModificaById!', 16, 1)
		RETURN
	END

	-- Calcolo provenienza da utente
	SET @Provenienza = dbo.LeggePazientiProvenienza(@Identity)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante PazientiOutputModificaById!', 16, 1)
		RETURN
	END
	---------------------------------------------------
	-- MODIFICA ETTORE 2014-04-25:
	--			Normalizzazione dei codici ISTAT dei comuni
	---------------------------------------------------
	SELECT @ComuneNascitaCodice = dbo.NormalizzaCodiceIstatComune(@ComuneNascitaCodice)
	SELECT @ComuneResCodice = dbo.NormalizzaCodiceIstatComune(@ComuneResCodice)
	SELECT @ComuneDomCodice = dbo.NormalizzaCodiceIstatComune(@ComuneDomCodice)
	---------------------------------------------------
	-- MODIFICA ETTORE 2014-04-25: 
	--			Verifica incoerenza Istat
	---------------------------------------------------
	DECLARE @IstatErrorMessage VARCHAR(128)
	DECLARE @IstatErrorCode INT
	DECLARE @TableIstatErrorCode AS TABLE (ERROR_CODE INTEGER)
	INSERT INTO @TableIstatErrorCode (ERROR_CODE )
	EXECUTE IstatWsIncoerenzaIstatVerifica @Identity, @ComuneNascitaCodice, @ComuneResCodice, @ComuneDomCodice, @DataNascita
	SELECT @IstatErrorCode = ERROR_CODE  FROM @TableIstatErrorCode 
	SELECT @IstatErrorMessage = dbo.LookUpIstatErrorCode(@IstatErrorCode)
	IF @IstatErrorCode > 0 
	BEGIN
		RAISERROR(@IstatErrorMessage , 16,1)
		RETURN
	END
	--		
	-- Aggiorna record
	--
	EXEC dbo.PazientiWsBaseUpdate @Identity, @Id, @Provenienza, @IdProvenienza, @Tessera, @Cognome, @Nome, @DataNascita, @Sesso, 
									@ComuneNascitaCodice, @NazionalitaCodice, @CodiceFiscale, @ComuneResCodice, 
									@SubComuneRes, @IndirizzoRes, @LocalitaRes, @CapRes, @ComuneDomCodice, @SubComuneDom, 
									@IndirizzoDom, @LocalitaDom, @CapDom, @IndirizzoRecapito, @LocalitaRecapito, 
									@Telefono1, @Telefono2, @Telefono3
	--						
	-- Restituisce l'Id del record
	--
	SELECT Id 
	FROM PazientiAttiviResult
	WHERE ID = @Id
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputModificaById] TO [ExecuteBiztalk]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputModificaById] TO [DataAccessSql]
    AS [dbo];

