





-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetRefertoDataMax2]
(
	  @IdPaziente UNIQUEIDENTIFIER
	, @FromDataPartizione SMALLDATETIME
)
RETURNS DATETIME
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-21: tenta di leggere la data dell'ultimo referto eseguendo un parsing dei dati scritti
		in PazientiAnteprima. Se non trova esegue la function [dbo].[GetRefertoDataMax2]
*/
	DECLARE @RetVar DATETIME = NULL
	DECLARE @Stringa VARCHAR(2048) = NULL
	DECLARE @Anteprimareferti VARCHAR(2048) = NULL
	--
	-- Leggo da PazientiAnteprima.Anteprimareferti 
	--
	SELECT @AnteprimaReferti = AnteprimaReferti FROM PazientiAnteprima WHERE Idpaziente = @IdPaziente
	IF ISNULL(@AnteprimaReferti,'') = ''
	BEGIN 
		--
		-- Eseguo il calcolo al momento
		--
		SELECT 
			@RetVar = MAX(DataReferto) 
		FROM 
			store.RefertiBase AS RefertiBase WITH(NOLOCK) 
			INNER JOIN dbo.GetPazientiDaCercareByIdSac(@IdPaziente) Pazienti
				ON  RefertiBase.IdPaziente = Pazienti.Id
		WHERE 
				Cancellato = 0    -- Non i cancellati
			AND StatoRichiestaCodice <> 3 --non gli annullati
			AND dbo.GetRefertiIsConfidenziale(RefertiBase.Id, RefertiBase.DataPartizione) = 0 --non i confidenziali  
			AND DataPartizione > @FromDataPartizione		
	END
	ELSE
	BEGIN
		--
		-- Eseguo split di @AnteprimaReferti usando come separatore '<br/>' e trovo la riga che contiene la stringa 'Ultimo referto:'
		-- Se non la trovo è perchè @AnteprimaReferti è composta solo dal testo 'Numero referti: 0' e quindi @RetVar deve rimanere NULL
		--
		SELECT TOP 1 @Stringa = [String]  FROM dbo.StringSplit(@AnteprimaReferti, '<br/>', 0) WHERE [String] like '%Ultimo referto:%'
		IF ISNULL(@Stringa , '') <> ''
		BEGIN
			DECLARE @DataStringa AS VARCHAR(10)
			DECLARE @PosStart AS INT = CHARINDEX('(', @Stringa) 
			DECLARE @PosEnd AS INT = CHARINDEX(')', @Stringa, @PosStart + 1) 
			--
			-- Se ho trovato '(' e ')'
			-- 
			IF @PosEnd <> 0 AND @PosStart <> 0
			BEGIN 
				SET @DataStringa = SUBSTRING(@Stringa, @PosStart + 1, @PosEnd-@PosStart + 1)
				--
				-- La data è scritta nel formato gg/MM/AAAA (format=103)
				--
				DECLARE @Day VARCHAR(2) = SUBSTRING(@DataStringa, 1, 2)
				DECLARE @Month VARCHAR(2) = SUBSTRING(@DataStringa, 4, 2)
				DECLARE @Year VARCHAR(4) = SUBSTRING(@DataStringa, 7, 4) 
				DECLARE @DateODBCFormat AS VARCHAR(10) = @Year + '-' + @Month + '-' + @Day
				--Verifico se è una data:
				IF ISDATE(@DateODBCFormat) = 1
					SET @RetVar = CONVERT(datetime, @DataStringa , 103) 
			END 
		END
	END
	--
	--
	--
	RETURN @RetVar
END
