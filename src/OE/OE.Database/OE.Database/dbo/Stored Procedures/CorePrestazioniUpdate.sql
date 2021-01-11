
-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-11-18, eliminato il parametro @IDParametroSpecifico
-- Description:	Aggiorna la prestazione
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniUpdate]
	  @Codice varchar(16)
	, @IDTicketModifica uniqueidentifier
	, @Descrizione varchar(256)
	, @IDSistemaErogante uniqueidentifier
AS
BEGIN
--
-- 2012-09-14 Modificata da Sandro per non aggiornare le
--            descizioni, ma riattivarlo se non è attivo
--
	--SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY

		--Controlla se c'è disattivato
		IF EXISTS (SELECT ID FROM Prestazioni WHERE Codice = @Codice AND IDSistemaErogante = @IDSistemaErogante AND Attivo = 0)
		BEGIN
			------------------------------
			-- UPDATE Se disattivato riattivo
			------------------------------		
			UPDATE Prestazioni
				SET   DataModifica = @DataModifica
					, IDTicketModifica = @IDTicketModifica
					, Descrizione = @Descrizione
					, Attivo = 1
				WHERE Codice = @Codice AND IDSistemaErogante = @IDSistemaErogante
					AND Attivo = 0
			
			SELECT @@ROWCOUNT AS [ROWCOUNT]
		END
		ELSE
		BEGIN
			------------------------------
			-- UPDATE finto
			------------------------------		
			--UPDATE Prestazioni
			--	SET	  DataModifica = @DataModifica
			--		, IDTicketModifica = @IDTicketModifica
			--	WHERE Codice = @Codice AND IDSistemaErogante = @IDSistemaErogante
			--		AND Attivo = 1
			SELECT CONVERT(INT, 1) AS [ROWCOUNT]
		END
		
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
    ON OBJECT::[dbo].[CorePrestazioniUpdate] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniUpdate] TO [DataAccessWs]
    AS [dbo];

