



-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Create date: 2018-10-09 Aggiunto controllo che query LDAP non in errore
-- Description:	Sincronizza le membership degli oggetti presenti nel DB attivi
--					Cerca l'appartenenza ai gruppi di utenti e gruppi
-- =============================================
CREATE PROCEDURE [dbo].[SyncOrganigrammaMembri]
 @DataFrom AS DATETIME = NULL
,@Simulazione BIT = 0
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @CountPrint INT = 0

	DECLARE @DomainName nvarchar(255) = dbo.ConfigNetbiosDomainName()

----------------------------------------------------

---				Importa le membership

----------------------------------------------------

	SELECT @CountPrint = COUNT(*) FROM [dbo].[OggettiActiveDirectory]
						WHERE Attivo = 1
							AND Utente LIKE @DomainName + '\%'
							AND (DataModificaEsterna > @DataFrom OR @DataFrom IS NULL)
	PRINT 'Trovati ' + CONVERT(VARCHAR(10), @CountPrint) + ' utenti'

	IF @Simulazione = 1
		PRINT '--Modalità silulazione!'

	-- Cerco le membership di ogniuno
	DECLARE @RetGroups TABLE (objectGUID varbinary(16), cn nvarchar(255), distinguishedName nvarchar(4000)
								, sAMAccountName nvarchar(255), sAMAccountType int
								, displayName nvarchar(255), mail nvarchar(255)
								, whenChanged datetime
							)

	DECLARE @IdUtente uniqueidentifier
	DECLARE @Utente varchar(255)
	DECLARE @Descrizione varchar(255)
	DECLARE @UserSamAccountName nvarchar(255)
	DECLARE @ErrorMember bit

	DECLARE CursorUtenti CURSOR STATIC READ_ONLY FOR
						SELECT Id, Utente, Descrizione
						FROM [dbo].[OggettiActiveDirectory]
						WHERE Attivo = 1
							AND Utente LIKE @DomainName + '\%'
							AND (DataModificaEsterna > @DataFrom OR @DataFrom IS NULL)

	OPEN CursorUtenti
	FETCH NEXT FROM CursorUtenti INTO @IdUtente, @Utente, @Descrizione
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ErrorMember = 0
		SET @UserSamAccountName = NULL
		SET @UserSamAccountName = SUBSTRING(@Utente, CHARINDEX('\', @Utente) + 1, 255)

		PRINT '############################################################################'
		PRINT 'Cerco i gruppi dell''utente ' + @Utente + '; sam=' + @UserSamAccountName
		
		BEGIN TRY
			--Leggo i dati da AD
			INSERT @RetGroups EXEC [AdsiGetGroupsBySamAccountName] @UserSamAccountName
			SET @ErrorMember = 0

			--Membership trovate
			SELECT @CountPrint = COUNT(*) FROM @RetGroups WHERE sAMAccountType != 268435457
			PRINT '--Trovate ' + CONVERT(VARCHAR(10), @CountPrint) + ' membership'
		END TRY
		BEGIN CATCH
			SET @ErrorMember = 1

			PRINT '--ERRORE durante  [dbo].[AdsiGetGroupsBySamAccountName] ' + @UserSamAccountName
			DELETE FROM @RetGroups
		END CATCH

		--Membership solo se non errore
		IF @ErrorMember = 0
		BEGIN
			IF @Simulazione = 1
			BEGIN
				--
				-- Print membership trovati
				--
				DECLARE @ListMemberOf VARCHAR(8000)
				SET @ListMemberOf = ''

				SELECT @ListMemberOf = @ListMemberOf + '  --' + sAMAccountName + CHAR(13) + CHAR(10)
					FROM @RetGroups
				PRINT @ListMemberOf
			END

			--Da inserire  ----------------------------------------------------------------------
			--PRINT 'Inserisce le nuove membership'
			IF @Simulazione = 0
			BEGIN

				INSERT INTO [dbo].[OggettiActiveDirectoryUtentiGruppi]
						   ([IdUtente]
						   ,[IdGruppo])	   
				SELECT DISTINCT
						@IdUtente AS [IdUtente],
						CONVERT(UNIQUEIDENTIFIER, objectGUID) AS [IdGruppo]
				FROM @RetGroups
				WHERE NOT EXISTS (			-- Non c'è già la membership
								SELECT *
								FROM  [dbo].[OggettiActiveDirectoryUtentiGruppi] WITH(NOLOCK)
								WHERE [IdGruppo] = CONVERT(UNIQUEIDENTIFIER, objectGUID)
									AND [IdUtente] = @IdUtente
								)
					AND EXISTS (				--C'è il gruppo
								SELECT *
								FROM  [dbo].[OggettiActiveDirectory] WITH(NOLOCK)
								WHERE [Id] = CONVERT(UNIQUEIDENTIFIER, objectGUID)
								)

			--Membership inserite
			SET @CountPrint = @@ROWCOUNT
			IF @CountPrint > 0
				PRINT '--Membership inserite ' + CONVERT(VARCHAR(10), @CountPrint)

			END ELSE BEGIN

				SELECT DISTINCT @CountPrint = COUNT(objectGUID)
				FROM @RetGroups
				WHERE NOT EXISTS (			-- Non c'è già la membership
								SELECT *
								FROM  [dbo].[OggettiActiveDirectoryUtentiGruppi] WITH(NOLOCK)
								WHERE [IdGruppo] = CONVERT(UNIQUEIDENTIFIER, objectGUID)
									AND [IdUtente] = @IdUtente
								)
					AND EXISTS (				--C'è il gruppo
								SELECT *
								FROM  [dbo].[OggettiActiveDirectory] WITH(NOLOCK)
								WHERE [Id] = CONVERT(UNIQUEIDENTIFIER, objectGUID)
								)
				IF @CountPrint > 0
					PRINT '--Membership inserite ' + CONVERT(VARCHAR(10), @CountPrint)
			END

			-- Da cancellare -------------------------------------------------------------------------------
			--PRINT 'Cancello gli uteni orfani'
			IF @Simulazione = 0
			BEGIN	
				DELETE FROM  [dbo].[OggettiActiveDirectoryUtentiGruppi]
				WHERE NOT EXISTS (
								SELECT *
								FROM  @RetGroups
								WHERE CONVERT(UNIQUEIDENTIFIER, objectGUID) = [IdGruppo]
								)
					AND [IdUtente] = @IdUtente
			
				--Membership cancellate
				SET @CountPrint = @@ROWCOUNT
				IF @CountPrint > 0
					PRINT '--Membership cancellate ' + CONVERT(VARCHAR(10), @CountPrint)
			
			END ELSE BEGIN

				SELECT @CountPrint = COUNT(*)
				FROM  [dbo].[OggettiActiveDirectoryUtentiGruppi]
				WHERE NOT EXISTS (
								SELECT *
								FROM  @RetGroups
								WHERE CONVERT(UNIQUEIDENTIFIER, objectGUID) = [IdGruppo]
								)
					AND [IdUtente] = @IdUtente

				IF @CountPrint > 0
					PRINT '--Membership cancellate ' + CONVERT(VARCHAR(10), @CountPrint)
			END
		END
		-----------------------------------------------------------------------------------------------
		-- Vuoto la lista per il prossimo gruppo
		DELETE FROM @RetGroups
		FETCH NEXT FROM CursorUtenti INTO @IdUtente, @Utente, @Descrizione
	END
	CLOSE CursorUtenti
	DEALLOCATE CursorUtenti					
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SyncOrganigrammaMembri] TO [adsi_dataaccess]
    AS [dbo];

