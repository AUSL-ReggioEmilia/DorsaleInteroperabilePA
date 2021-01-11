
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modificato il 2018-10-02 Usa SP [dbo].[AdsiGetAllUsers]
--							Flag cancella le membership dei disabilitati
-- Modificato il 2020-11-06 Verifica anche che Utente sia univoco durante INSERT
--
-- Description:	Sincronizza gli utenti DiRoleManager
-- =============================================
CREATE PROCEDURE [dbo].[SyncOrganigrammaUtenti]
	@DataFrom AS DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @CountPrint INT

	-- Non cancella le membership degli utenti disabilitati
	DECLARE @DeleteMemberDisabled BIT = 1

	-- Lista degli utenti da sincronizzare
	DECLARE @RetUsers TABLE (objectGUID varbinary(16), cn nvarchar(255)
								, distinguishedName nvarchar(4000), sAMAccountName nvarchar(255), sAMAccountType int
								, displayName nvarchar(255), sn nvarchar(255), givenName nvarchar(255)
								, mail nvarchar(255), codiceFiscale nvarchar(255), matricola nvarchar(255)
								, whenChanged datetime
							)
	
	--Eseguo SP che li legge per lettera
	IF DATEDIFF(DAY , @DataFrom, GETDATE()) > 2 OR @DataFrom IS NULL
	BEGIN
		-- se delta maggiore di 2 giorni o tutto uso la più partizionata
		INSERT @RetUsers EXEC [dbo].[AdsiGetAllUsers2] 0, 0, 0, 0, @DataFrom, 0
	END ELSE BEGIN
		INSERT @RetUsers EXEC [dbo].[AdsiGetAllUsers] 0, 0, 0, 0, @DataFrom, 0
	END

	-- Rimuovo i ritornati per differenze di millisecondi
	IF NOT @DataFrom IS NULL
		DELETE @RetUsers WHERE whenChanged <= @DataFrom

	--Utenti trovati totali
	SELECT @CountPrint = COUNT(*) FROM @RetUsers
	PRINT 'Trovati ' + CONVERT(VARCHAR(10), @CountPrint) + ' utenti'

	DECLARE @DomainName nvarchar(255) = dbo.ConfigNetbiosDomainName()


	-- Da cancellare ------------------------------------------------------------			
	-- Se non incrementale
	IF @DataFrom IS NULL
	BEGIN
		PRINT 'Cancello gli utenti orfani'
						
		UPDATE  [dbo].[OggettiActiveDirectory]
		SET Attivo = 0, 
			Utente = CONVERT(VARCHAR(128), @DomainName + '\' + CONVERT(VARCHAR(40), Id)),
			DataModifica = GETUTCDATE(),
			UtenteModifica = SUSER_NAME()
		WHERE Attivo = 1
			AND Tipo = 'Utente'
			AND Utente LIKE @DomainName + '\%'
			AND NOT EXISTS (
							SELECT *
							FROM  @RetUsers AdUser
							WHERE Id = CONVERT(UNIQUEIDENTIFIER, AdUser.objectGUID)
							)

		--Utenti cancellati
		PRINT '--Utenti ' + CONVERT(VARCHAR(10), @@ROWCOUNT) + ' cancellati'
	END
	ELSE
	BEGIN
		PRINT 'Disabilito gli utenti con Account = e ID <>'

		UPDATE  [dbo].[OggettiActiveDirectory]
		SET Attivo = 0, 
			Utente = CONVERT(VARCHAR(128), @DomainName + '\' + CONVERT(VARCHAR(40), Id)),
			DataModifica = GETUTCDATE(),
			UtenteModifica = SUSER_NAME()
		WHERE Attivo = 1
			AND Tipo = 'Utente'
			AND Utente LIKE @DomainName + '\%'
			AND EXISTS (
						SELECT *
						FROM  @RetUsers AdUser
						WHERE Id <> CONVERT(UNIQUEIDENTIFIER, AdUser.objectGUID)
							AND Utente = AdUser.sAMAccountName
						)
		--Utenti cancellati
		PRINT '--Utenti con Account=sAMAccountName e ID<>objectGUID ' + CONVERT(VARCHAR(10), @@ROWCOUNT) + ' disabilitati'
	END
	
	-- Cancello membership di utenti disabilitati
	IF @DeleteMemberDisabled = 1 
	BEGIN
		DELETE FROM  [dbo].[OggettiActiveDirectoryUtentiGruppi]
				WHERE IdUtente IN (
								SELECT Id
								FROM  [dbo].[OggettiActiveDirectory]
								WHERE Attivo = 0
									AND Utente LIKE @DomainName + '\%'
									)
							
		--Membership utenti disabilitati cancellate
		PRINT '--Membership utenti disabilitati ' + CONVERT(VARCHAR(10), @@ROWCOUNT) + ' cancellate'
	END

	-- Da inserire ---------------------------------------------
	PRINT 'Inserisco i nuovi utenti'

	INSERT INTO [dbo].[OggettiActiveDirectory]
		([Id],[Utente],[Tipo],[Descrizione]
		  ,[Cognome],[Nome],[CodiceFiscale]
		  ,[Matricola],[Email],[Attivo]
		  ,[DataModificaEsterna])

	SELECT DISTINCT
			CONVERT(UNIQUEIDENTIFIER, objectGUID) AS Id,
			CONVERT(VARCHAR(128), @DomainName + '\' + sAMAccountName) AS Utente,
			'Utente' AS Tipo,
			CONVERT(VARCHAR(256), displayName) AS Descrizione,
			CONVERT(VARCHAR(64), sn) AS Cognome,
			CONVERT(VARCHAR(64), givenName) AS Nome,
			CONVERT(VARCHAR(16), codiceFiscale) AS CodiceFiscale,
			CONVERT(VARCHAR(64), matricola) AS Matricola,
			CONVERT(VARCHAR(256), mail) AS Email,
			1 AS Attivo,
			whenChanged AS DataModificaEsterna
	FROM @RetUsers
	WHERE NOT EXISTS (
						SELECT *
						FROM  [dbo].[OggettiActiveDirectory] WITH(NOLOCK)
						WHERE Id = CONVERT(UNIQUEIDENTIFIER, objectGUID)
						)
		--2020-11-06 Verifica anche che Utente sia univoco
		AND NOT EXISTS (
						SELECT *
						FROM  [dbo].[OggettiActiveDirectory] WITH(NOLOCK)
						WHERE [Utente] = CONVERT(VARCHAR(128), @DomainName + '\' + sAMAccountName)
						)

	--Utenti inseriti
	PRINT '--Utenti ' + CONVERT(VARCHAR(10), @@ROWCOUNT) + ' inseriti'
	
	-- Da aggiornare ------------------------------------------------------------------------
	PRINT 'Aggiorno gli utenti esistenti'

	UPDATE [dbo].[OggettiActiveDirectory]
	  SET  Utente = CONVERT(VARCHAR(128), @DomainName + '\' + sUtenti.sAMAccountName),
			Descrizione = CONVERT(VARCHAR(256), sUtenti.displayName),
			Cognome = CONVERT(VARCHAR(64), sUtenti.sn),
			Nome = CONVERT(VARCHAR(64), sUtenti.givenName),
			CodiceFiscale = CONVERT(VARCHAR(16), sUtenti.codiceFiscale),
			Matricola = CONVERT(VARCHAR(64), sUtenti.matricola),
			Email = CONVERT(VARCHAR(256), sUtenti.mail),
			Attivo = 1,
			DataModifica = GETUTCDATE(),
			UtenteModifica = SUSER_NAME(),
			DataModificaEsterna = sUtenti.whenChanged

	FROM [dbo].[OggettiActiveDirectory] oad
		INNER JOIN @RetUsers sUtenti
			ON oad.Id = CONVERT(UNIQUEIDENTIFIER, sUtenti.objectGUID)

	WHERE  oad.Utente != CONVERT(VARCHAR(128), @DomainName + '\' + sUtenti.sAMAccountName)
		OR ISNULL(oad.Descrizione, '') != CONVERT(VARCHAR(256), ISNULL(sUtenti.displayName, ''))
		OR ISNULL(oad.Cognome, '') != CONVERT(VARCHAR(64), ISNULL(sUtenti.sn, ''))
		OR ISNULL(oad.Nome, '') != CONVERT(VARCHAR(64), ISNULL(sUtenti.givenName, ''))
		OR ISNULL(oad.CodiceFiscale, '') != CONVERT(VARCHAR(16), ISNULL(sUtenti.codiceFiscale, ''))
		OR ISNULL(oad.Matricola, '') != CONVERT(VARCHAR(64), ISNULL(sUtenti.matricola, ''))
		OR ISNULL(oad.Email, '') != CONVERT(VARCHAR(256), ISNULL(sUtenti.mail, ''))
		OR oad.Attivo = 0
		OR oad.DataModificaEsterna != whenChanged
		
	--Utenti modificati
	PRINT '--Utenti ' + CONVERT(VARCHAR(10), @@ROWCOUNT) + ' modificati'
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SyncOrganigrammaUtenti] TO [adsi_dataaccess]
    AS [dbo];

