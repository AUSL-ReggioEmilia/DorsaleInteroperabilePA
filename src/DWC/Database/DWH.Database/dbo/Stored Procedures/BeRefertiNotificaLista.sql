


-- =============================================
-- Author:		Simone Bitti
-- Create date: 2017-03-16
-- Description: Ottiene la lista dei referti da rinotificare
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- =============================================
CREATE PROCEDURE [dbo].[BeRefertiNotificaLista]
(
	@AziendaErogante AS VARCHAR(16)=NULL
	,@SistemaErogante AS VARCHAR(16)=NULL
	,@IdPaziente AS UNIQUEIDENTIFIER=NULL
	,@DallaData AS DATETIME
	,@AllaData AS DATETIME
	--,@NumSogliaReferti AS INTEGER = 1000
	--,@NumRef INTEGER OUTPUT

)
AS
BEGIN
	SET NOCOUNT ON	
		DECLARE @REF TABLE (ID UNIQUEIDENTIFIER, DataPartizione SMALLDATETIME)

		--SE ALLA DATA NON E' VALORIZZATA ALLORA LA IMPOSTO ALLA DATA CORRENTE.
		IF @AllaData IS NULL SET @AllaData = GETDATE()

		/*
		* TROVO GLI ID PAZIENTE CHE APPARTENGONO ALLA STESSA CATENA DI FUSIONE DELL'ID PAZIENTE PASSATO.
		*/
		DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
		IF NOT @IdPaziente IS NULL
		BEGIN 
			SELECT @IdPaziente = dbo.GetPazienteAttivoByIdSac(@IdPaziente)
			INSERT INTO @TablePazienti(Id)
			SELECT Id FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)	
		END 
		
		/*
		*ESEGUO UN CONTEGGIO PRELIMINARE.
		*/
		--SELECT @NumRef = COUNT (*)
		--FROM  
		--	store.RefertiBase AS R WITH(NOLOCK)
		--	INNER JOIN dbo.[SAC_Pazienti] AS P WITH(NOLOCK) --Tutti i pazienti anche i figli
		--		ON R.IdPaziente = P.Id
		--	LEFT OUTER JOIN store.RefertiAttributi AS RA
		--		ON R.Id = RA.IdRefertiBase
		--			AND R.DataPartizione = RA.DataPartizione
		--			AND RA.Nome = 'ImportazioneStorica'
		--WHERE
		--	    (@DallaData IS NULL OR R.DataModifica BETWEEN @DallaData AND @AllaData)
		--	AND (@aziendaErogante IS NULL OR R.AziendaErogante = @aziendaErogante)
		--	AND (@sistemaErogante IS NULL OR R.SistemaErogante = @sistemaErogante)
		--	AND (
		--		@idPaziente IS NULL OR R.IdPaziente IN (SELECT Id FROM @TablePazienti)
		--		)
		--	AND ISNULL(CAST(RA.Valore AS VARCHAR(1)), '0') = '0' 
		--	AND R.IdPaziente <>'00000000-0000-0000-0000-000000000000'
		/*
		* SE SONO MAGGIORI DI @NumSogliaReferti ALLORA NON ESEGUO LA RICERCA
		*/
		
		--IF (@NumRef > @NumSogliaReferti)
		--BEGIN
		--	RETURN
		--END


		/*
		* SE SONO QUI @NumRef E' MINORE DI @NumSogliaReferti  E QUINDI ESEGUO LA RICERCA.
		*/
		INSERT INTO @REF (ID, DataPartizione)
		SELECT
			R.Id, R.DataPartizione
		FROM  
			store.RefertiBase AS R WITH(NOLOCK)
			LEFT OUTER JOIN store.RefertiAttributi AS RA
				ON R.Id = RA.IdRefertiBase
					AND R.DataPartizione = RA.DataPartizione
					AND RA.Nome = 'ImportazioneStorica'
		WHERE
			    (@DallaData IS NULL OR R.DataModifica BETWEEN @DallaData AND @AllaData)
			AND (@aziendaErogante IS NULL OR R.AziendaErogante = @aziendaErogante)
			AND (@sistemaErogante IS NULL OR R.SistemaErogante = @sistemaErogante)
			AND (
				@idPaziente IS NULL OR R.IdPaziente IN (SELECT Id FROM @TablePazienti)
				)
			AND ISNULL(CAST(RA.Valore AS VARCHAR(1)), '0') = '0' 
			AND R.IdPaziente <>'00000000-0000-0000-0000-000000000000'
		ORDER BY 
			R.DataReferto DESC

		OPTION (RECOMPILE)

		SELECT 
			R.ID,
			R.IdEsterno,
			R.IdPaziente,
			R.DataInserimento,
			R.DataModifica,
			R.AziendaErogante,
			R.SistemaErogante,
			R.RepartoErogante,
			R.DataReferto,
			R.NumeroReferto,
			R.NumeroNosologico,
			R.NumeroPrenotazione,
			P.Cognome AS Cognome,
			P.Nome AS Nome,
			P.CodiceFiscale AS CodiceFiscale,
			P.DataNascita AS DataNascita,
			P.ComuneNascitaNome AS ComuneNascita,
			P.Tessera AS CodiceSanitario,		
			RepartoRichiedenteCodice,
			RepartoRichiedenteDescr,
			CONVERT(VARCHAR(16), R.StatoRichiestaCodice) AS StatoRichiestaCodice,
			dbo.GetRefertoStatoDesc(R.RepartoErogante, StatoRichiestaCodice, '' ) AS StatoRichiestaDescr,
			dbo.GetRefertoCodiciOscuramento2 --recupero l'eventuale codice oscuramento
			(
				R.Id,  
				R.IdEsterno, 
				R.DataPartizione,
				R.AziendaErogante,
				R.SistemaErogante,
				R.StrutturaEroganteCodice,
				R.NumeroNosologico,
				R.RepartoRichiedenteCodice,
				R.RepartoErogante,
				R.NumeroPrenotazione,
				R.NumeroReferto,
				R.IdOrderEntry,
				R.Confidenziale
			) AS CodiceOscuramento
		
		FROM store.Referti R WITH(NOLOCK)
			INNER JOIN @Ref AS REF
				ON R.Id = REF.ID
				AND R.DataPartizione = REF.DataPartizione
			INNER JOIN dbo.[SAC_Pazienti] P WITH(NOLOCK) --Tutti i pazienti anche i figli
				ON R.IdPaziente = P.Id
		ORDER BY 
			R.DataReferto DESC

	

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRefertiNotificaLista] TO [ExecuteFrontEnd]
    AS [dbo];

