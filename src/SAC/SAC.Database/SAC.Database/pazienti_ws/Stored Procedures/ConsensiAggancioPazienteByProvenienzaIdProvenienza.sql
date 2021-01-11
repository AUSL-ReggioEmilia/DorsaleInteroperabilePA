-- =============================================
-- Author:		Stefano P
-- Create date: 2017-01-02
-- Description:	Ricerca paziente per metodo aggiunta consensi. Viene restituito l'IdPaziente a prescindere dal suo stato di Attivo/Fuso
-- =============================================
CREATE PROCEDURE [pazienti_ws].[ConsensiAggancioPazienteByProvenienzaIdProvenienza]
(
	@Identity VARCHAR(64)
	, @ProvenienzaPaziente varchar(16)	
	, @IdProvenienzaPaziente varchar(64)
) AS
BEGIN
	BEGIN TRY

		DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
		SET NOCOUNT ON;
	
		--	
		-- Controllo accesso
		--
		IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
		BEGIN
			EXEC dbo.PazientiEventiAccessoNegato @Identity, 0, @ProcName, 'Utente non ha i permessi di lettura!'
			RAISERROR('Errore di controllo accessi!', 16, 1)
			RETURN
		END		
		--
		-- Cerco il paziente per @ProvenienzaPaziente, @IdProvenienzaPaziente
		--
		SELECT TOP 1 
				Id			
		FROM dbo.Pazienti
		WHERE 
			Provenienza = @ProvenienzaPaziente 
			AND IdProvenienza = @IdProvenienzaPaziente
			AND Disattivato IN (0,2) --solo attivi o fusi
		ORDER BY
			Disattivato


	END TRY
	BEGIN CATCH
		---------------------------------------------------
		--     GESTIONE ERRORI (LOG E PASSO FUORI)
		---------------------------------------------------
		DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE()    
		EXEC dbo.ConsensiEventiAvvertimento @Identity, 0, @ProcName, @msg
		-- PASSO FUORI L'ECCEZIONE
		;THROW;

	END CATCH	
END