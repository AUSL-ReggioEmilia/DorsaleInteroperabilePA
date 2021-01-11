CREATE PROCEDURE  [dbo].[PazientiFusioniOttieniCandidatoPadre]
(
	@IdPazDaFondere		UNIQUEIDENTIFIER
	, @IdPazientePadre	UNIQUEIDENTIFIER OUTPUT 
)
AS
BEGIN 
/*
	Questa è una funzione interna, richiamabil solo dalle SP e non direttamente
	Dato il paziente @IdPazDaFondere:
		1) Verifica se il merge è possibile in base alla fascia oraria
		2) Verifica se il merge è possibile in base allamprovenienza e al livello di attendibilità del paziente da fondere
		3) Trova il padre a LivelloAttendibilità e peso maggiore	
		4) Restituisce quello che sarà il candidato padre o NULL se non lo trova
		6) Se si verifica errore viene eseguito un RAISEERROR
*/

	SET NOCOUNT ON;
	DECLARE @ProvenienzaPazDaFondere varchar(16)
	DECLARE @LivAttendPazDaFondere tinyint
	DECLARE @IdProvenienzaPazDaFondere varchar(64)
	DECLARE @CognomePazDaFondere varchar(64)
	DECLARE @NomePazDaFondere varchar(64)
	DECLARE @CodiceFiscalePazDaFondere varchar(16) 
	DECLARE @DisattivatoPazDaFondere TINYINT
	---------------------------------------
	DECLARE @IdPadre uniqueidentifier
	DECLARE @LivAttendPadre tinyint
	DECLARE @CognomePadre varchar(64)
	DECLARE @NomePadre varchar(64)
	DECLARE @DataNascitaPadre datetime
	DECLARE @SessoPadre varchar(1)
	DECLARE @ComuneNascitaCodicePadre varchar(6)
	DECLARE @TesseraPadre varchar(16)
	DECLARE @CodiceFiscalePadre varchar(16) 

	DECLARE @TmpTable AS TABLE (Id UNIQUEIDENTIFIER, LivelloAttendibilita TINYINT, Peso integer)
	BEGIN TRY
		--
		-- Inizializzo la variabile di ritorno con il paziente che si sta tentando di fondere
		-- Se la fusione non avviene (per fascia oraria livello attendibilità, ecc ecc) restituisco il paziente stesso
		--
		SET @IdPazientePadre = NULL
		--
		-- Verifico se la fusione può avvenire per fascia oraria
		--
		IF dbo.GetPermessoFusioneByFasciaOraria() = 0 
			RETURN 
		--
		-- Trovo alcuni dati del paziente da fondere
		--
		SELECT @ProvenienzaPazDaFondere= Provenienza
			, @IdProvenienzaPazDaFondere = IdProvenienza
			, @LivAttendPazDaFondere = LivelloAttendibilita
			, @CognomePazDaFondere = Cognome
			, @NomePazDaFondere = Nome
			, @CodiceFiscalePazDaFondere = CodiceFiscale
			, @DisattivatoPazDaFondere = Disattivato
		FROM 
			Pazienti 
		WHERE 
			Id = @IdPazDaFondere 

		--
		-- Verifico se questo paziente può essere fuso altrimento esco
		--
		IF (dbo.GetPermessoFusioneByProvenienza(@ProvenienzaPazDaFondere) = 0) 
			OR dbo.GetPermessoFusioneByLivelloAttendibilita(@LivAttendPazDaFondere) = 0
			RETURN 
		
		--
		-- Popolo la tabella temporanea e determino il peso di ogni posizioni anagrafica che soddisfa la condizione di merge 
		--
		INSERT INTO @TmpTable (Id, LivelloAttendibilita, Peso)
		SELECT Id, LivelloAttendibilita, 
				dbo.GetPesoPaziente(Cognome, Nome, DataNascita, Sesso, ComuneNascitaCodice, Tessera) AS Peso
		FROM 
			Pazienti
		WHERE 
			--Criterio di Merge: Cognome, Nome, CodiceFiscale
			(CodiceFiscale = @CodiceFiscalePazDaFondere AND Cognome = @CognomePazDaFondere AND Nome = @NomePazDaFondere)
			AND Disattivato = 0									--solo gli attivi
			AND Id <> @IdPazDaFondere							--escludo il paziente da fondere dalla ricerca
			AND LivelloAttendibilita >= @LivAttendPazDaFondere	--pazienti con livello di attendibilità superiore o uguale
			--Modifica Ettore 2013-04-02 : NON SI DEVE FONDERE SE CODICE FISCALE = '0000000000000000'
			AND CodiceFiscale <> '0000000000000000'
			
			
		IF (SELECT COUNT(*) FROM @TmpTable ) > 0 
		BEGIN
			--
			-- A questo punto prelevo dalla tabella temporanea la posizione che sarà il padre della fusione: 
			-- quella con max livello attendibilità e max peso
			--
			SELECT TOP 1 @IdPadre = Id 
			FROM @TmpTable 
			ORDER BY LivelloAttendibilita DESC, Peso DESC -- Fondamentale questo ordinamento
			--
			-- Setto il candidato ad essere padre di fusione
			--
			SET @IdPazientePadre = @IdPadre	
		END	
	END TRY
	BEGIN CATCH 
		DECLARE @ErroMsg varchar(4000)
		SET @ErroMsg = 'Errore durante PazientiFusioniOttieniCandidatoPadre.'
		SET @ErroMsg = @ErroMsg + ' ' + ERROR_MESSAGE()
		RAISERROR(@ErroMsg, 16, 1)
	END CATCH
END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiFusioniOttieniCandidatoPadre] TO [DataAccessWs]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiFusioniOttieniCandidatoPadre] TO [DataAccessDll]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiFusioniOttieniCandidatoPadre] TO [DataAccessUi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiFusioniOttieniCandidatoPadre] TO [DataAccessSql]
    AS [dbo];

