




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modifiy Date: 2017-07-28 ETTORE: 
--				1) non si cancella il record del sinonimo associato alla provenienza da cancellare se è multipla nella catena di fusione
--				2) si cancella tale provenienza solo se è associata alla catena di fusione di @IdPaziente (facendo un demerge di una anagrafica doppia potre cancellare l'associazione [provenienza, idProvenienza] con altra root di fusione
-- =============================================
CREATE PROCEDURE [dbo].[PazientiBaseDeMerge_Prova]
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
DECLARE @IdRoot AS UNIQUEIDENTIFIER = NULL
DECLARE @IsProvenienzaIdProvenienzaMultiplaInCatenaFusione BIT = 0
	SET NOCOUNT ON;
	IF @IdPaziente IS NULL
	BEGIN
		RETURN 0
	END
	--
	-- Controllo che il paziente appartenga ad una fusione come paziente fuso
	--
	--SELECT @IdRoot = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente AND Abilitato = 1
	SELECT @IdRoot = dbo.GetPazienteRootByPazienteId(@IdPaziente)
	PRINT '@IdRoot: ' + ISNULL(CAST(@IdRoot AS VARCHAR(40)), 'NULL')
	IF @IdRoot IS NULL OR @IdRoot = @IdPaziente --allora il padre è se stesso quindi non è fuso
	BEGIN
		RETURN 0
	END
	--
	-- Ricavo Provenienza e IdProvenienza del paziente
	--		
	SELECT @Provenienza = Provenienza, @IdProvenienza = IdProvenienza FROM Pazienti WHERE Id = @IdPaziente 

	--
	-- Se nella catena di fusione ci sono più record con [provenienza , IdProvenienza] uguali NON DEVO cancellare 
	-- dai sinonimi le relazioni IdRoot - [provenienza , IdProvenienza]. 
	--
	IF (SELECT COUNT(*) FROM 
		PazientiFusioni AS PF
		INNER JOIN Pazienti AS P
			ON PF.IdPazienteFuso = P.Id
	WHERE 
		P.Provenienza = @Provenienza 
		AND P.IdProvenienza = @IdProvenienza
		AND PF.Abilitato = 1
		) > 1
	BEGIN 
		SET @IsProvenienzaIdProvenienzaMultiplaInCatenaFusione = 1
	END 
	
	PRINT '@IsProvenienzaIdProvenienzaMultiplaInCatenaFusione; ' + CAST(@IsProvenienzaIdProvenienzaMultiplaInCatenaFusione AS VARCHAR(10))
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

		-- SINONIMI: cancello i sinonimi di @IdPaziente appartenenti alla catena di fusione di @IdPaziente
		IF @IsProvenienzaIdProvenienzaMultiplaInCatenaFusione = 0
		BEGIN

			delete from PazientiSinonimi 
			where 
				--IdPAziente = @IdRoot   --QUESTO FILTRO CAUSA UN MAGGIORAMENTO DEL PROGRESSIVO DI FUSIONE...
				--AND 
				Provenienza = @Provenienza and IdProvenienza = @IdProvenienza
		END
		
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
    ON OBJECT::[dbo].[PazientiBaseDeMerge_Prova] TO [DataAccessDll]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseDeMerge_Prova] TO [DataAccessSql]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseDeMerge_Prova] TO [DataAccessUi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiBaseDeMerge_Prova] TO [DataAccessWs]
    AS [dbo];

