




-- =============================================
-- Author:		Pichierri
-- Create date: ???
-- Description:	Cancella le esenzioni di un paziente
-- Modify date: 2018-05-28 - ETTORE: gestione delle esenzioni per PROVENIENZA dell'@Utente
--							Vengono cancellate solo le esenzioni con la stessa provenienza del paziente
-- Modify date: 2018-12-17 - ETTORE: non cancello le esenzioni Qb e QM se YEAR(GETDATE()) <= '2019'
--									non cancello le esenzioni RE1,RE2,RE3,RE4 YEAR(GETDATE()) > '2018'
--									Questa modifica dovrà essere rimossa fra qualche mese
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgEsenzioniRemove]
	( @Utente varchar(64)
	, @IdProvenienza varchar(64)
	)
AS
BEGIN

DECLARE @IdPaziente AS uniqueidentifier
DECLARE @Provenienza AS varchar(16)

DECLARE @RowCount AS integer

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Cerco Id del paziente
	---------------------------------------------------

	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante [PazientiMsgEsenzioniRemove]!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	SET @IdPaziente = dbo.GetPazienteIdByProvenienza(@Provenienza, @IdProvenienza)
	IF @IdPaziente IS NULL
	BEGIN
		RAISERROR('Errore di Paziente non trovato durante [PazientiMsgEsenzioniRemove]!', 16, 1)
		SELECT 2002 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Rimuovo tutte i record 
	---------------------------------------------------
	SET NOCOUNT OFF;

	IF  YEAR(GETDATE()) < '2019'
	BEGIN 
		--Anno 2018: non cancello le esenzioni con codice 'QB', 'QM'
		DELETE FROM PazientiEsenzioni
		WHERE 
			IdPaziente = @IdPaziente
			--2018-05-28 - ETTORE: gestione delle esenzioni per PROVENIENZA dell'@Utente
			--Cancello le esenzioni con stessa provenienza del paziente
			AND Provenienza = @Provenienza
			AND NOT CodiceEsenzione IN ('QB', 'QM')
	END 
	ELSE
	BEGIN 
		--Anno 2019 e maggiori: non cancello le esenzioni con codice 'RE1', 'RE2', 'RE3', 'RE4'
		DELETE FROM PazientiEsenzioni
		WHERE 
			IdPaziente = @IdPaziente
			--2018-05-28 - ETTORE: gestione delle esenzioni per PROVENIENZA dell'@Utente
			--Cancello le esenzioni con stessa provenienza del paziente
			AND Provenienza = @Provenienza
			AND NOT CodiceEsenzione IN ('RE1', 'RE2', 'RE3', 'RE4')
	END

	SET @RowCount = @@ROWCOUNT

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Completato
	---------------------------------------------------

	SELECT @RowCount AS ROW_COUNT
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	
	RETURN 1

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgEsenzioniRemove] TO [DataAccessDll]
    AS [dbo];

