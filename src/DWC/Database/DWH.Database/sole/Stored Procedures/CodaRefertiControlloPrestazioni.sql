
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-03-27
-- Modify date: 
-- Description:	Controlla se esiste una prestazione configurata in AbilitazioniPrestazioni
--				RETURN = numero delle prestazioni trovate
--				OUTPUT = Dettaglio
-- =============================================
CREATE PROCEDURE [sole].[CodaRefertiControlloPrestazioni]
(
 @IdReferto UNIQUEIDENTIFIER
,@AziendaErogante VARCHAR(16)
,@SistemaErogante VARCHAR(16)
,@PrestazioneCodici VARCHAR(MAX) OUTPUT		--Risultato
,@DisabilitaControlliBloccoInvio BIT OUTPUT	--Risultato
,@OreRitardoInvio INT OUTPUT				--Risultato
)
AS
BEGIN
	
	SET NOCOUNT ON

	DECLARE @Trovati INT
	--
	-- Lista delle prestazioni da verificare
	--
	DECLARE @AbilPre TABLE ([PrestazioneCodice] varchar(12),
							[DisabilitaControlliBloccoInvio] bit,
							[OreRitardoInvio] int)

	INSERT INTO @AbilPre ([PrestazioneCodice], [DisabilitaControlliBloccoInvio], [OreRitardoInvio])
	SELECT LTRIM(RTRIM([PrestazioneCodice])), [DisabilitaControlliBloccoInvio], [OreRitardoInvio]
	FROM [sole].[AbilitazioniPrestazioni]
	WHERE [Abilitato] = 1
		AND [AziendaErogante] = @AziendaErogante
		AND[SistemaErogante] = @SistemaErogante
	
	--
	-- Trovate delle prestazioni da controllare
	--
	IF EXISTS (SELECT * FROM @AbilPre)
	BEGIN	  
		--
		-- Cerco tramite xPath se ci solo le prestazioni
		--
		DECLARE @tblResult TABLE ([PrestazioneCodice] varchar(12),
								[DisabilitaControlliBloccoInvio] bit,
								[OreRitardoInvio] int)
		INSERT INTO @tblResult
		SELECT ap.[PrestazioneCodice], ap.[DisabilitaControlliBloccoInvio], ap.[OreRitardoInvio]
		FROM @AbilPre ap
			INNER JOIN [store].[PrestazioniBase] pb
				ON ap.[PrestazioneCodice] = pb.[PrestazioneCodice]
		WHERE pb.[IdRefertiBase] = @IdReferto
		--
		-- Reset risultati
		--
		SET @Trovati = 0
		SET @DisabilitaControlliBloccoInvio = 0
		SET @OreRitardoInvio = 0
		SET @PrestazioneCodici = ''
		--
		-- Legge valori aggregati dalla table
		--
		SELECT @Trovati = COUNT(*)
			, @DisabilitaControlliBloccoInvio = ISNULL(CONVERT(BIT, MAX(CONVERT(INT, [DisabilitaControlliBloccoInvio]))), 0)
			, @OreRitardoInvio = MIN([OreRitardoInvio])
		FROM @tblResult

		SELECT @PrestazioneCodici = @PrestazioneCodici + [PrestazioneCodice] + ', ' 
		FROM @tblResult

		SET @PrestazioneCodici = NULLIF(@PrestazioneCodici, '')
		SET @PrestazioneCodici = LEFT(@PrestazioneCodici, LEN(@PrestazioneCodici) - 1)

		RETURN ISNULL(@Trovati, 0)

	END ELSE BEGIN
		--
		-- Nessun controllo eseguito
		--
		RETURN -1
	END
END