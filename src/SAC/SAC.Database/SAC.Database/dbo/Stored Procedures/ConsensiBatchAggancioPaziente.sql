
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-09-02
-- Description:	Batch di aggancio consensi a posizioni 
--				anagrafiche create post-inserimento consenso
-- =============================================
CREATE PROCEDURE [dbo].[ConsensiBatchAggancioPaziente] 

AS
BEGIN

	--
	-- Variabili
	--
	DECLARE @IdConsenso uniqueidentifier
	DECLARE @PazienteProvenienza varchar(16)
	DECLARE @PazienteIdProvenienza varchar(64)
	DECLARE @PazienteCodiceFiscale varchar(16)
	DECLARE @IdPaziente uniqueidentifier
	DECLARE @Utente varchar(64)

	SET @Utente = USER_NAME()

	SET NOCOUNT ON;

	--
	-- Recupero i consensi anonimi
	--
	DECLARE crsConsensiAnonimi CURSOR STATIC READ_ONLY FOR
		SELECT Id, PazienteProvenienza, PazienteIdProvenienza, PazienteCodiceFiscale 
		FROM Consensi with(nolock)
		WHERE IdPaziente = '00000000-0000-0000-0000-000000000000'

	--
	-- Apro il cursore dei consensi anonimi
	--
	OPEN crsConsensiAnonimi
	FETCH NEXT FROM crsConsensiAnonimi INTO @IdConsenso, @PazienteProvenienza, @PazienteIdProvenienza, @PazienteCodiceFiscale

	--
	-- Ciclo le righe
	--
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--
		-- La condizione necessaria per iniziare la ricerca del paziente è quella dove la coppia
		-- di attributi PazienteProvenienza e PazienteIdProvenienza sono entrambi valorizzati o nulli
		--
		IF NOT ((@PazienteProvenienza IS NOT NULL AND @PazienteIdProvenienza IS NOT NULL) OR
			(@PazienteProvenienza IS NULL AND @PazienteIdProvenienza IS NULL))
		BEGIN
			--
			-- Avanzo il cursore dei consensi anonimi
			-- 			
			FETCH NEXT FROM crsConsensiAnonimi INTO @IdConsenso, @PazienteProvenienza, @PazienteIdProvenienza, @PazienteCodiceFiscale

			CONTINUE
		END

		--
		-- Cerco il paziente per IdProvenienza
		--
		IF (@PazienteProvenienza IS NOT NULL ) AND (@PazienteIdProvenienza IS NOT NULL)
		BEGIN
			SELECT @IdPaziente = Id 
			FROM Pazienti with(nolock)
			WHERE Provenienza = @PazienteProvenienza AND IdProvenienza = @PazienteIdProvenienza AND Disattivato = 0
		END

		--
		-- Cerco il paziente per CodiceFiscale qualora la ricerca per IdProvenienza non ha prodotto risultato
		--
		IF (@IdPaziente IS NULL) AND (ISNULL(@PazienteCodiceFiscale,'') <> '')
		BEGIN
			SELECT @IdPaziente = Id
			FROM Pazienti with(nolock)
			WHERE CodiceFiscale = @PazienteCodiceFiscale AND Disattivato = 0
		END

		BEGIN TRY
			--
			-- Se trovo il paziente aggancio il consenso
			--
			IF @IdPaziente IS NOT NULL
			BEGIN
				--
				-- Update del consenso
				--
				UPDATE Consensi SET IdPaziente = @IdPaziente WHERE Id = @IdConsenso

				--
				-- Notifica del consenso
				--
				EXEC dbo.ConsensiNotificheAdd @IdConsenso, '0', @Utente

				--
				-- Invalido il paziente precedentemente trovato
				-- 
				SET @IdPaziente = NULL

				--
				-- Debug
				--
				PRINT 'Consenso ' + CAST(@IdConsenso as varchar(40)) + ' agganciato correttamente al paziente ' + CAST(@IdPaziente as varchar(40))
			END

		END TRY
		BEGIN CATCH

				--
				-- Invalido il paziente
				-- 
				SET @IdPaziente = NULL

				--
				-- Stampa errore
				--
				PRINT '[Error number: ' + ERROR_NUMBER() + '] Error message: ' + ERROR_MESSAGE()

		END CATCH

		--
		-- Avanzo il cursore dei consensi anonimi
		-- 			
		FETCH NEXT FROM crsConsensiAnonimi INTO @IdConsenso, @PazienteProvenienza, @PazienteIdProvenienza, @PazienteCodiceFiscale

	END

	--
	-- Chiudo il cursore dei consensi anonimi
	--
	CLOSE crsConsensiAnonimi
	DEALLOCATE crsConsensiAnonimi

END

