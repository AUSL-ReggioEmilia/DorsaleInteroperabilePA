
CREATE PROCEDURE [dbo].[PazientiDropTableLHABT]
	
AS

DECLARE @DataSessione AS DATETIME

BEGIN
	SET @DataSessione = GETDATE()
	
	BEGIN TRAN
	
	BEGIN TRY

		-- Prenoto i primi pazienti
		UPDATE dbo.PazientiDropTable
		SET DataInvio = @DataSessione,
			Inviato = 1
		WHERE Id IN (	
						SELECT TOP 1 Id
						FROM dbo.PazientiDropTable
						WHERE (Inviato = 0)
							--
							-- Ritardo di 30 secondi
							--
							AND DataLog < DATEADD(second, -30, GETDATE())
						ORDER BY DataLog
					)
	
		-- Ritorno i pazienti prenotati
		SELECT IdLha 
		FROM dbo.PazientiDropTable
		WHERE DataInvio = @DataSessione
			--and 1=2 --da scommentare quando tutto pronto
		ORDER BY DataLog
		
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
	
	END CATCH
END

---

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiDropTableLHABT] TO [Execute Biztalk]
    AS [dbo];

