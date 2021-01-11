


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modificato il 2018-10-02 Usa SP [dbo].[AdsiGetAllGroups]

-- Description:	Sincronizza i gruppi DiRoleManager
-- =============================================
CREATE PROCEDURE [dbo].[SyncOrganigrammaGruppi]
	@DataFrom AS DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @CountPrint INT = 0

	-- Lista dei gruppi da sincronizzare
	DECLARE @RetGroups TABLE (objectGUID varbinary(16), cn nvarchar(255), distinguishedName nvarchar(4000)
								, sAMAccountName nvarchar(255), sAMAccountType int
								, displayName nvarchar(255), mail nvarchar(255)
								, whenChanged datetime
							)
	
	--Eseguo SP che li legge per lettera
	IF DATEDIFF(DAY , @DataFrom, GETDATE()) > 2 OR @DataFrom IS NULL
	BEGIN
		-- se delta maggiore di 2 giorni o tutto uso la più partizionata
		INSERT @RetGroups EXEC [dbo].[AdsiGetAllGroups2] 0, 0, @DataFrom, 0
	END ELSE BEGIN
		INSERT @RetGroups EXEC [dbo].[AdsiGetAllGroups] 0, 0, @DataFrom, 0
	END

	-- Rimuovo i ritornati per differenze di millisecondi
	IF NOT @DataFrom IS NULL
		DELETE @RetGroups WHERE whenChanged <= @DataFrom

	--Gruppi trovati totali
	SELECT @CountPrint = COUNT(*) FROM @RetGroups
	PRINT '--Trovati ' + CONVERT(VARCHAR(10), @CountPrint) + ' gruppi'

	DECLARE @DomainName nvarchar(255) = dbo.ConfigNetbiosDomainName()

	-- Da cancellare	----------------------------------------------------------
	-- Se non incrementale			
	IF @DataFrom IS NULL
	BEGIN
		PRINT 'Cancello i gruppi orfani'
						
		UPDATE  [dbo].[OggettiActiveDirectory]
		SET Attivo = 0,
			Utente = CONVERT(VARCHAR(128), @DomainName + '\' + CONVERT(VARCHAR(40), Id)),
			DataModifica = GETUTCDATE(),
			UtenteModifica = SUSER_NAME()
		WHERE Attivo = 1
			AND Tipo = 'Gruppo'
			AND Utente LIKE @DomainName + '\%'
			AND NOT EXISTS (
							SELECT *
							FROM @RetGroups AdGroup
							WHERE CONVERT(UNIQUEIDENTIFIER, AdGroup.objectGUID) = Id
							)

		--Gruppi cancellati
		PRINT '--Gruppi ' + CONVERT(VARCHAR(10), @@ROWCOUNT) + ' cancellati'
	END
	ELSE
	BEGIN
		PRINT 'Disabilito i gruppi con Account = e ID <>'

		UPDATE  [dbo].[OggettiActiveDirectory]
		SET Attivo = 0, 
			Utente = CONVERT(VARCHAR(128), @DomainName + '\' + CONVERT(VARCHAR(40), Id)),
			DataModifica = GETUTCDATE(),
			UtenteModifica = SUSER_NAME()
		WHERE Attivo = 1
			AND Tipo = 'Gruppo'
			AND Utente LIKE @DomainName + '\%'
			AND EXISTS (
						SELECT *
						FROM  @RetGroups AdGroup
						WHERE Id <> CONVERT(UNIQUEIDENTIFIER, AdGroup.objectGUID)
							AND Utente = AdGroup.sAMAccountName
						)
		--Utenti cancellati
		PRINT '--Gruppi con Account=sAMAccountName e ID<>objectGUID ' + CONVERT(VARCHAR(10), @@ROWCOUNT) + ' disabilitati'
	END	
	
	-- Cancello membership di gruppi disabilitati

	PRINT 'Cancello membership di gruppi disabilitati'
					
	DELETE FROM  [dbo].[OggettiActiveDirectoryUtentiGruppi]
	WHERE IdUtente IN (
					SELECT Id
					FROM  [dbo].[OggettiActiveDirectory]
					WHERE Attivo = 0
						AND Tipo = 'Gruppo'
						AND Utente LIKE @DomainName + '\%'
					)
		OR IdGruppo IN (
					SELECT Id
					FROM  [dbo].[OggettiActiveDirectory]
					WHERE Attivo = 0
						AND Tipo = 'Gruppo'
						AND Utente LIKE @DomainName + '\%'
					)
	--Membership cancellati
	PRINT '--Membership di gruppi disabilitati ' + CONVERT(VARCHAR(10), @@ROWCOUNT) + ' cancellate'
		
	-- Da inserire   --------------------------------------------------------------
	
	PRINT 'Inserisco i nuovi gruppi'

	INSERT INTO [dbo].[OggettiActiveDirectory]
		([Id],[Utente],[Tipo],[Descrizione]
		  ,[Email],[Attivo]
		  ,[DataModificaEsterna])
	SELECT DISTINCT
			CONVERT(UNIQUEIDENTIFIER, objectGUID) AS Id,
			CONVERT(VARCHAR(128), @DomainName + '\' + sAMAccountName) AS Utente,
			'Gruppo' AS Tipo,
			CONVERT(VARCHAR(256), displayName) AS Descrizione,
			CONVERT(VARCHAR(256), mail) AS Email,
			1 AS Attivo,
			whenChanged AS DataModificaEsterna
	FROM @RetGroups
	WHERE NOT EXISTS (
						SELECT *
						FROM  [dbo].[OggettiActiveDirectory] WITH(NOLOCK)
						WHERE Id = CONVERT(UNIQUEIDENTIFIER, objectGUID)
						)

	--Gruppi inseriti
	PRINT '--Gruppi ' + CONVERT(VARCHAR(10), @@ROWCOUNT) + ' inseriti'

	-- Da aggiornare   ------------------------------------------------------------

	PRINT 'Aggiorno i gruppi esistenti'

	UPDATE [dbo].[OggettiActiveDirectory]
	  SET  Utente = CONVERT(VARCHAR(128), @DomainName + '\' + sAMAccountName),
			Descrizione = CONVERT(VARCHAR(256), displayName),
			Email = CONVERT(VARCHAR(256), mail),
			Attivo = 1,
			DataModifica = GETUTCDATE(),
			UtenteModifica = SUSER_NAME(),
			DataModificaEsterna = whenChanged
	FROM [dbo].[OggettiActiveDirectory] oad
		INNER JOIN @RetGroups gruppi
			ON oad.Id = CONVERT(UNIQUEIDENTIFIER, gruppi.objectGUID)
	WHERE  oad.Utente != @DomainName + '\' + gruppi.sAMAccountName
		OR ISNULL(oad.Descrizione, '') != ISNULL(gruppi.displayName, '')
		OR ISNULL(oad.Email, '') != ISNULL(gruppi.mail, '')
		OR oad.Attivo = 0
		OR oad.DataModificaEsterna != whenChanged

	--Gruppi modificati
	PRINT '--Gruppi ' + CONVERT(VARCHAR(10), @@ROWCOUNT) + ' modificati'
	

----------------------------------------------------

---				Importa le membership

----------------------------------------------------

	DECLARE @RetMembers TABLE (objectGUID varbinary(16), cn nvarchar(255), distinguishedName nvarchar(4000)
								, sAMAccountName nvarchar(255), sAMAccountType int
								, displayName nvarchar(255), mail nvarchar(255)
								, whenChanged datetime
							)

	DECLARE @ErrorMember bit
	DECLARE @GroupId uniqueidentifier
	DECLARE @GroupDistinguishedName nvarchar(4000)

	DECLARE CursorGruppi CURSOR STATIC READ_ONLY FOR
				SELECT CONVERT(UNIQUEIDENTIFIER, objectGUID) AS Id, distinguishedName FROM @RetGroups

	OPEN CursorGruppi
	FETCH NEXT FROM CursorGruppi INTO @GroupId, @GroupDistinguishedName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Cerco gli utenti del gruppo ' + @GroupDistinguishedName
		
		BEGIN TRY
			--Leggo i dati da AD
			INSERT @RetMembers EXEC [dbo].[AdsiGetMembersByDn] @GroupDistinguishedName
			SET @ErrorMember = 0
			
			--Membership trovate
			SELECT @CountPrint = COUNT(*) FROM @RetMembers
			PRINT '--Trovate ' + CONVERT(VARCHAR(10), @CountPrint) + ' members'
		END TRY
		BEGIN CATCH
			PRINT '--ERRORE durante  [dbo].[AdsiGetMembersByDn] @GroupDistinguishedName'
			DELETE FROM @RetMembers
			SET @ErrorMember = 1
		END CATCH

		--Se non errore provo con query partizionate
		IF @ErrorMember = 1
		BEGIN
			BEGIN TRY
				--Leggo i dati da AD partizionati
				INSERT @RetMembers EXEC [dbo].[AdsiGetMembersByDn2] @GroupDistinguishedName
				SET @ErrorMember = 0
			
				--Membership trovate
				SELECT @CountPrint = COUNT(*) FROM @RetMembers
				PRINT '--Trovate ' + CONVERT(VARCHAR(10), @CountPrint) + ' members (metodo partizionato)'
			END TRY
			BEGIN CATCH
				PRINT '--ERRORE durante  [dbo].[AdsiGetMembersByDn2] @GroupDistinguishedName'
				DELETE FROM @RetMembers
				SET @ErrorMember = 1
			END CATCH
		END

		--Membership solo se non errore
		IF @ErrorMember = 0
		BEGIN
			--
			-- Print members trovati
			--
			DECLARE @ListMember VARCHAR(8000)
			SET @ListMember = ''

			SELECT @ListMember = @ListMember + '  --' + sAMAccountName + CHAR(13) + CHAR(10)
			FROM @RetMembers

			PRINT @ListMember

			--Da inserire  ----------------------------------------------------------------------
			--PRINT 'Inserisce le nuove membership'

			INSERT INTO [dbo].[OggettiActiveDirectoryUtentiGruppi]
					   ([IdUtente]
					   ,[IdGruppo])	   
			SELECT DISTINCT
					CONVERT(UNIQUEIDENTIFIER, objectGUID) AS [IdUtente],
					@GroupId AS [IdGruppo]
			FROM @RetMembers
			WHERE NOT EXISTS (
							SELECT *
							FROM  [dbo].[OggettiActiveDirectoryUtentiGruppi] WITH(NOLOCK)
							WHERE [IdGruppo] = @GroupId
								AND [IdUtente] = CONVERT(UNIQUEIDENTIFIER, objectGUID)
							)
				AND EXISTS (
							SELECT *
							FROM  [dbo].[OggettiActiveDirectory] WITH(NOLOCK)
							WHERE [Id] = CONVERT(UNIQUEIDENTIFIER, objectGUID)
							)

			--Membership inserite
			SET @CountPrint = @@ROWCOUNT
			IF @CountPrint > 0
				PRINT '--Membership ' + CONVERT(VARCHAR(10), @CountPrint) + ' inserite'

			-- Da cancellare -------------------------------------------------------------------------------
			--PRINT 'Cancello gli uteni orfani'
						
			DELETE FROM  [dbo].[OggettiActiveDirectoryUtentiGruppi]
			WHERE NOT EXISTS (
							SELECT *
							FROM  @RetMembers
							WHERE CONVERT(UNIQUEIDENTIFIER, objectGUID) = [IdUtente]
							)
				AND [IdGruppo] = @GroupId

			--Membership cancellate
			SET @CountPrint = @@ROWCOUNT
			IF @CountPrint > 0
				PRINT '--Membership ' + CONVERT(VARCHAR(10), @CountPrint) + ' cancellate'

		END  --error=0
		
		-------------------------------------------------------------------------------------------------
		-- Vuoto la lista per il prossimo gruppo
		DELETE FROM @RetMembers
		FETCH NEXT FROM CursorGruppi INTO @GroupId, @GroupDistinguishedName
		
	END --while
	CLOSE CursorGruppi
	DEALLOCATE CursorGruppi
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SyncOrganigrammaGruppi] TO [adsi_dataaccess]
    AS [dbo];

