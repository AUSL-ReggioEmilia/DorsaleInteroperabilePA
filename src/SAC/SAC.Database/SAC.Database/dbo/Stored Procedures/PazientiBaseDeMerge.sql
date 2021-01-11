

CREATE PROCEDURE [dbo].[PazientiBaseDeMerge]
(
	  @IdPaziente uniqueidentifier  -- @Id della posizione che deve tornare attiva
)	  
AS
BEGIN
------------------------------------------------------------------------------------------------------
--
-- La stored procedure restituisce 0 se eseguita con successo, 1 se si è verificato un errore
-- In caso di errore viene eseguto rollback della transazione
--
------------------------------------------------------------------------------------------------------
DECLARE @Provenienza varchar(16)
DECLARE @IdProvenienza varchar(64)

	SET NOCOUNT ON;
	--
	-- Controllo che il paziente appartenga ad una fusione come paziente fuso
	--
	IF NOT EXISTS(SELECT Id FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente)
		RETURN 0

	--
	-- Ricavo Provenienza e IdProvenienza del paziente
	--		
	SELECT @Provenienza = Provenienza, @IdProvenienza = IdProvenienza FROM Pazienti WHERE Id = @IdPaziente 
		
	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------
	BEGIN TRAN
	BEGIN TRY
	
		declare @TAB AS TABLE (IdPaziente uniqueidentifier, IdPazienteFuso uniqueidentifier, ProvenienzaFuso varchar(16), IdProvenienzaFuso varchar(64))
		
		insert into @TAB (IdPaziente, IdPazienteFuso, ProvenienzaFuso, IdProvenienzaFuso)		
		select IdPaziente, IdPazienteFuso, P.Provenienza, P.IdProvenienza  FROM 
			(select IdPaziente from PazientiFusioni where IdPazienteFuso = @IdPaziente) AS Padri
			CROSS JOIN 
			(select IdPazienteFuso from PazientiFusioni where IdPaziente = @IdPaziente) AS Figli
			inner join Pazienti as P on P.Id = Figli.IdPazienteFuso
			
		-- FUSIONI: cancello le relazioni "padri di IdPaziente" e "figli di IdPaziente"
		delete PazientiFusioni 
			from PazientiFusioni inner join @TAB AS TAB
			ON TAB.IdPaziente = PazientiFusioni.IdPaziente 
				AND TAB.IdPazienteFuso = PazientiFusioni.IdPazienteFuso
		-- FUSIONI: cancello relazione fra i "padri di IdPaziente" e IdPaziente come figlio
		delete from PazientiFusioni where IdPazienteFuso = @IdPaziente
		
		-- SINONIMI: cancello le relazioni "padri di IdPaziente" e "figli di IdPaziente"
		delete PazientiSinonimi 
			from PazientiSinonimi inner join @TAB AS TAB
			ON PazientiSinonimi.IdPaziente = TAB.IdPaziente 
				AND Provenienza + IdProvenienza = TAB.ProvenienzaFuso + TAB.IdProvenienzaFuso
		-- SINONIMI: cancello i sinonimi di IdPaziente
		delete from PazientiSinonimi where Provenienza = @Provenienza and IdProvenienza = @IdProvenienza
		
		-- Rendo attiva la posizione nella tabella Pazienti
		update Pazienti set Disattivato=0 , DataDisattivazione = NULL where Id = @IdPaziente	

		-- Commit
		COMMIT
		
	END TRY	
	BEGIN CATCH
		ROLLBACK
		
		-- Raiserror
		DECLARE @ERROR_MESSAGE nvarchar(2048)
		SET @ERROR_MESSAGE = ERROR_MESSAGE()

		RAISERROR(@ERROR_MESSAGE, 16, 1)
	END CATCH
	
END














GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseDeMerge] TO [DataAccessWs]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseDeMerge] TO [DataAccessDll]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseDeMerge] TO [DataAccessUi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseDeMerge] TO [DataAccessSql]
    AS [dbo];

