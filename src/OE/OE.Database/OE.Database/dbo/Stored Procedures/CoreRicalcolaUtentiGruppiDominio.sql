
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2018-02-06 Sandro - Nuova tabella [dbo].[UtentiGruppiDominio]
-- Description:	Inserisce o aggiorna la cache dei Gruppi di AD
-- =============================================
CREATE PROCEDURE [dbo].[CoreRicalcolaUtentiGruppiDominio]
 @UserName varchar(64)
,@Minuti int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataCorrente datetime
	SELECT @DataCorrente = [DataModifica] FROM [dbo].[UtentiGruppiDominio] WITH(NOLOCK) WHERE [UserName] = @UserName
	--
	-- Aggiorna se più vecchia di n minuti o se minuti = 0
	--
	IF @Minuti < 1 OR DATEADD(minute, @Minuti, @DataCorrente) < GETUTCDATE() OR @DataCorrente IS NULL
	BEGIN

		-- Legge la lista dei Gruppi di utenti dal SAC (sincronizzato con AD)
		DECLARE @xmlGruppiUtente xml
		SET @xmlGruppiUtente = (SELECT * FROM [dbo].[RicalcolaGruppiOePerUtente] (@UserName) Gruppo
									FOR XML AUTO, ROOT('GruppiUtente')
								)
		--
		-- Inserisco a aggiorno se c'è la data
		--
		IF NOT @DataCorrente IS NULL
		BEGIN
			UPDATE [dbo].[UtentiGruppiDominio]
				SET [CacheGruppiUtente] = @xmlGruppiUtente
					, [DataModifica] = GETUTCDATE()
			WHERE [UserName] = @UserName

		END ELSE BEGIN

			INSERT INTO [dbo].[UtentiGruppiDominio] ([UserName], [DataModifica], [CacheGruppiUtente])
				VALUES (@UserName, GETUTCDATE(), @xmlGruppiUtente)
		END

	END

	RETURN @@ERROR
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreRicalcolaUtentiGruppiDominio] TO [DataAccessWs]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreRicalcolaUtentiGruppiDominio] TO [DataAccessMsg]
    AS [dbo];

