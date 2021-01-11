



CREATE PROCEDURE [dbo].[_Util_CancellaPaziente]
(
	@IdPaziente UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRANSACTION
	BEGIN TRY	
		PRINT 'Inizio cancellazione dell''anagrafica ' + CAST(@IdPaziente AS VARCHAR(40))
		--
		-- Cancello le notifiche paziente
		--
		DELETE FROM PazientiNotificheUtenti 
			WHERE IdPazientiNotifica IN(
				SELECT Id from PazientiNotifiche WHERE IdPaziente = @IdPaziente
			)
		PRINT 'Delete PazientiNotificheUtenti: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'

		DELETE FROM PazientiNotifiche 
			WHERE IdPaziente = @IdPaziente
		PRINT 'Delete PazientiNotifiche: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'
		--
		-- Cancello le notifiche consensi associate al paziente
		--
		DELETE FROM ConsensiNotificheUtenti  WHERE IdConsensiNotifica IN (
			SELECT Id FROM ConsensiNotifiche  WHERE IdConsenso IN (
				SELECT Id FROM Consensi WHERE IdPaziente = @IdPaziente
			) 
		) 
		PRINT 'Delete ConsensiNotificheUtenti: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'
		
		DELETE FROM ConsensiNotifiche  WHERE IdConsenso IN (
			SELECT Id from Consensi WHERE IdPaziente = @IdPaziente
		)			
		PRINT 'Delete ConsensiNotifiche: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'
		--
		-- Cancello le esenzioni
		--
		DELETE FROM PazientiEsenzioni 
			WHERE IdPaziente = @IdPaziente
		PRINT 'Delete PazientiEsenzioni: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'
		--
		-- Cancello i consensi
		--
		DELETE FROM Consensi 
			WHERE IdPaziente = @IdPaziente
		PRINT 'Delete Consensi: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'
		--
		-- Cancello fusioni/sinonimi
		--
		IF NOT EXISTS (SELECT * FROM PazientiFusioni WHERE IdPaziente = @IdPaziente) 
		BEGIN
			--Il record non è nella colonna dei padri, quindi è foglia: cancello e basta
			PRINT 'IdPaziente ' + cast(@IdPaziente AS VARCHAR(40)) + ' è foglia.'
			DELETE FROM PazientiFusioni 
				WHERE (IdPaziente = @IdPaziente) OR (IdPazienteFuso = @IdPaziente)
			PRINT 'Delete PazientiFusioni: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'
		
			DELETE FROM PazientiSinonimi 
				WHERE IdPaziente = @IdPaziente
			PRINT 'Delete PazientiSinonimi per IdPaziente: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'

			DELETE FROM PazientiSinonimi 
			WHERE Provenienza + IdProvenienza IN (
				SELECT Provenienza + IdProvenienza FROM Pazienti 
						WHERE id = @IdPaziente
			)
			PRINT 'Delete PazientiSinonimi per [Provenienza,IdProvenienza]: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'

		END
		ELSE
		BEGIN
			PRINT 'IdPaziente ' + cast(@IdPaziente AS VARCHAR(40)) + ' NON è foglia.'
			DECLARE @IdRoot UNIQUEIDENTIFIER --Id del record padre della catena
			DECLARE @IdPadreDiretto UNIQUEIDENTIFIER --Id del record a cui è direttamente collegato l'id da cancellare
			--cerco la root
			SELECT @IdRoot = IdPaziente from PazientiFusioni where IdPazientefuso = @IdPaziente and Abilitato = 1 -- la ROOT
			IF @IdRoot IS NULL
			BEGIN
				RAISERROR('Impossibile trovare il padre della catena di fusione!', 16, 1)
				RETURN
			END 

			--Cerco il Padre diretto: BISOGNA AGGIUNGERE AND Abilitato=1?
			SELECT @IdPadreDiretto = IdPaziente from PazientiFusioni where IdPazientefuso = @IdPaziente and ProgressivoFusione = 1 
			--Se non trovo il Padre diretto cerco la Root
			IF @IdPadreDiretto IS NULL
				SET @IdPadreDiretto = @IdRoot 
			IF @IdPadreDiretto IS NULL
			BEGIN
				RAISERROR('Impossibile trovare il padre del record!', 16, 1)
				RETURN
			END 

			--Cerco il tree associato all'IdRoot (FONDAMENTALE) 
			DECLARE @Tree as table (Id INT, IdFiglio UNIQUEIDENTIFIER, ProvenienzaFiglio varchar(16), IdProvenienzaFiglio varchar(64)
									, IdPadre UNIQUEIDENTIFIER, Livello INT)
									--, ProvenienzaPadre varchar(16), IdProvenienzaPadre varchar(64))
			INSERT INTO @Tree (Id, IdFiglio, ProvenienzaFiglio, IdProvenienzaFiglio, IdPadre, Livello)
								--, ProvenienzaPadre, IdProvenienzaPadre)
			SELECT 
				TREE.Id --Ordinamento
				, TREE.IdFiglio
				, P_F.Provenienza AS ProvenienzaFiglio,  P_F.IdProvenienza AS IdProvenienzaFiglio
				, TREE.IdPadre
				, TREE.Livello
				--, P_P.Provenienza AS ProvenienzaPadre,  P_P.IdProvenienza AS IdProvenienzaPadre
			FROM [dbo].[GetTreeFusione] (@IdRoot) AS TREE 
				inner join Pazienti AS P_F 
					on P_F.Id = TREE.IdFiglio
				--inner join Pazienti AS P_P 
				--	on P_P.Id = TREE.IdPadre



			-------------DEBUG 
			--SELECT * from @Tree order by livello desc 
			--SELECT 'Ordine di demerge', * from @Tree order by Id desc 

			--Variabili cursore
			DECLARE @IdFiglio UNIQUEIDENTIFIER 
			DECLARE @IdPadre UNIQUEIDENTIFIER 
			DECLARE @ProvenienzaFiglio VARCHAR(16) 
			DECLARE @IdProvenienzaFiglio VARCHAR(64) 
			--DECLARE @ProvenienzaPadre VARCHAR(16) 
			--DECLARE @IdProvenienzaPadre VARCHAR(64) 

			--STACCO I RECORD FIGLI DEL PAZIENTE DA CANCELLARE A PARTIRE DALLE FOGLIE (FONDAMENTALE)
			DECLARE CursoreDemerge CURSOR READ_ONLY FOR
			SELECT IdPadre, IdFiglio, ProvenienzaFiglio, IdProvenienzaFiglio--, ProvenienzaPadre, IdProvenienzaPadre
			FROM @Tree 
			ORDER BY Id DESC --lo faccio per lavorare per eseguire il de-merge dalle foglie
			OPEN CursoreDemerge
			FETCH NEXT FROM CursoreDemerge INTO @IdPadre, @IdFiglio, @ProvenienzaFiglio, @IdProvenienzaFiglio--, @ProvenienzaPadre, @IdProvenienzaPadre
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN
					--Print 'Demerge da: ' + @ProvenienzaPadre + '-' + @IdProvenienzaPadre + ' di ' + @ProvenienzaFiglio + '-' + @IdProvenienzaFiglio 
					EXEC dbo.PazientiBaseDeMerge @IdFiglio
				END
				FETCH NEXT FROM CursoreDemerge INTO @IdPadre, @IdFiglio, @ProvenienzaFiglio, @IdProvenienzaFiglio--, @ProvenienzaPadre, @IdProvenienzaPadre
			END
			CLOSE CursoreDemerge
			DEALLOCATE CursoreDemerge

			--
			-- Aggiorno la tabella temporanea per sostituire l'IdPadreDiretto di IdPaziente
			--
			UPDATE @Tree
				set IdPadre = @IdPadreDiretto
			WHERE IdPadre = @IdPaziente
				OR IdFiglio = @IdPaziente

			-------------DEBUG 
			--SELECT 'Ordine di merge', * from @Tree order by Id DESC
			-- 
			-- RIATTACCO I RECORD FIGLI DEL PAZIENTE DA CANCELLARE AL suo padre diretto
			--
			DECLARE CursoreMerge CURSOR READ_ONLY FOR
			SELECT IdPadre, IdFiglio, ProvenienzaFiglio, IdProvenienzaFiglio--, ProvenienzaPadre, IdProvenienzaPadre
			FROM @Tree 
			ORDER BY Id DESC --FONDAMENTALE
			OPEN CursoreMerge 
			FETCH NEXT FROM CursoreMerge INTO @IdPadre, @IdFiglio, @ProvenienzaFiglio, @IdProvenienzaFiglio--, @ProvenienzaPadre, @IdProvenienzaPadre
			WHILE (@@fetch_status <> -1)
			BEGIN
				IF (@@fetch_status <> -2)
				BEGIN
					--Print 'Merge su : ' + @ProvenienzaPadre + '-' + @IdProvenienzaPadre + ' di ' + @ProvenienzaFiglio + '-' + @IdProvenienzaFiglio 
					EXEC dbo.PazientiBaseMerge   
						@IdPaziente = @IdPadre
						, @IdPazienteFuso = @IdFiglio
						, @ProvenienzaFuso = @ProvenienzaFiglio
						, @IdProvenienzaFuso = @IdProvenienzaFiglio
						, @Motivo = 3
						, @Note = NULL
				END
				FETCH NEXT FROM CursoreMerge INTO @IdPadre, @IdFiglio, @ProvenienzaFiglio, @IdProvenienzaFiglio--, @ProvenienzaPadre, @IdProvenienzaPadre
			END
			CLOSE CursoreMerge 
			DEALLOCATE CursoreMerge 


			DELETE FROM PazientiFusioni 
				WHERE (IdPaziente = @IdPaziente) OR (IdPazienteFuso = @IdPaziente)
			PRINT 'Delete PazientiFusioni: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'
		
			DELETE FROM PazientiSinonimi 
				WHERE IdPaziente = @IdPaziente
			PRINT 'Delete PazientiSinonimi per IdPaziente: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'

			DELETE FROM PazientiSinonimi 
			WHERE Provenienza + IdProvenienza IN (
				SELECT Provenienza + IdProvenienza from Pazienti 
						WHERE id = @IdPaziente
			)
			PRINT 'Delete PazientiSinonimi per [Provenienza,IdProvenienza]: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'

		END
		
		--
		-- Cancello le Anonimizzazioni
		--
		DELETE FROM PazientiAnonimizzazioni 
			WHERE IdSacAnonimo = @IdPaziente
		PRINT 'Delete PazientiAnonimizzazioni per [IdSacAnonimo]: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'
		
		--
		-- Cancello il record paziente
		--
		DELETE FROM Pazienti 
			WHERE id = @IdPaziente
		PRINT 'Delete Pazienti: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows'			
	
		COMMIT
		
	END TRY
	BEGIN CATCH
		--
		-- Segnalo l'errore
		--
		DECLARE @ErrorMsg as VARCHAR(4000)
		SET @ErrorMsg = ERROR_MESSAGE()
		--
		-- ROLLBACK
		--
		IF @@TRANCOUNT > 0
		BEGIN
		  ROLLBACK TRANSACTION;
		END
		--
		-- Mi assicuro di chiudere i cursori
		--
		BEGIN TRY
			CLOSE CursoreDemerge
			DEALLOCATE CursoreDemerge		
		END TRY
		BEGIN CATCH
		END CATCH

		BEGIN TRY
			DEALLOCATE CursoreMerge 
		END TRY
		BEGIN CATCH
		END CATCH

		--
		-- RAISE DELL'ERRORE
		--
		RAISERROR (@ErrorMsg , 16,1)

	END CATCH

END
