




-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-11-18, eliminato il parametro @IDParametroSpecifico
-- Description:	Inserisce una nuova prestazione
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniInsert]
	  @IDTicketInserimento uniqueidentifier
	, @Codice varchar(16)
	, @Descrizione varchar(256)
	, @Tipo tinyint
	, @IDSistemaErogante uniqueidentifier
	
AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
	BEGIN TRY

		--Controlla se c'è disattivato
		IF NOT EXISTS (SELECT ID FROM Prestazioni WHERE Codice = @Codice AND IDSistemaErogante = @IDSistemaErogante AND Attivo = 0)
		BEGIN
			------------------------------
			-- INSERT
			------------------------------		
			INSERT INTO Prestazioni
			(
				  ID
				, DataInserimento
				, DataModifica
				, IDTicketInserimento
				, IDTicketModifica
				, Codice
				, Descrizione
				, Tipo
				, Provenienza
				, IDSistemaErogante
			)
			VALUES
			(
				  @ID
				, @DataInserimento
				, @DataInserimento --DataModifica
				, @IDTicketInserimento
				, @IDTicketInserimento --IDTicketModifica
				, @Codice
				, @Descrizione
				, @Tipo
				, 3 -- Msg
				, @IDSistemaErogante
			)
		END
		ELSE
		BEGIN
			------------------------------
			-- UPDATE Riattivo il disattivato
			------------------------------		
			UPDATE Prestazioni
				SET	  DataInserimento = @DataInserimento
					, DataModifica = @DataInserimento
					, IDTicketInserimento = @IDTicketInserimento
					, IDTicketModifica = @IDTicketInserimento
					, Descrizione = @Descrizione
					, Tipo = @Tipo
					, Provenienza = 3
					, Attivo = 1
				WHERE Codice = @Codice AND IDSistemaErogante = @IDSistemaErogante
					AND Attivo = 0
		END
						
		SELECT @@ROWCOUNT AS [ROWCOUNT]
				
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
		
		SELECT @@ROWCOUNT AS [ROWCOUNT]
	END CATCH
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniInsert] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniInsert] TO [DataAccessWs]
    AS [dbo];

