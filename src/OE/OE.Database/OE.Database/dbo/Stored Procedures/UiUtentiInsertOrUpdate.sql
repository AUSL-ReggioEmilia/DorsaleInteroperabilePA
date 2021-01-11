
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-26
-- Modify date: 2018-10-16 - refactoty e lunghezza utente e desc
-- Description:	Controlla se l'utente ha accesso al OE , utente o gruppo
-- =============================================
CREATE PROCEDURE [dbo].[UiUtentiInsertOrUpdate]
(
 @Utente as varchar(256)
,@Descrizione as varchar(1024)
,@Attivo as bit
,@Delega as tinyint
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Tipo TINYINT = NULL
	DECLARE @ObjectGuid UNIQUEIDENTIFIER = NULL

	IF NOT EXISTS(SELECT * FROM Utenti WHERE Utente = @Utente)
    BEGIN
    
		--CONTROLLO SULLA PRESENZA DELL'UTENTE SU SAC
		SELECT @Tipo = 0, @ObjectGuid = Id
		FROM  SacOrganigramma.Utenti
		WHERE Utente = @Utente
			AND Attivo = 1		
		
		--CONTROLLO SULLA PRESENZA DEL GRUPPO SU SAC
		IF @Tipo IS NULL
		BEGIN
			SELECT @Tipo = 1, @ObjectGuid = Id
			FROM  SacOrganigramma.Gruppi
			WHERE Gruppo = @Utente
				AND Attivo = 1
		END
    
		IF @Tipo IS NOT NULL
		BEGIN
			INSERT INTO Utenti (ID, Utente, Descrizione, Attivo, Delega, Tipo, ObjectGuid)
			SELECT NEWID(), @Utente, @Descrizione, @Attivo, @Delega, @Tipo, @ObjectGuid
		END		
    
    END ELSE BEGIN

        UPDATE Utenti
		SET Descrizione = @Descrizione, 
			Attivo = @Attivo, 
			Delega = @Delega
        WHERE Utente = @Utente
    END
  
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUtentiInsertOrUpdate] TO [DataAccessUi]
    AS [dbo];

