

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-04-20
--
-- Description:	Calcola il valore dei giorni di archivazione
--				Il calcolo tiene conto che le ennuple posso coincidere parzialmente
--					e tramite un peso si raggruppano e ritornano in ordine
--				Deve tornare solo 1 record
--
-- =============================================
CREATE FUNCTION [dbo].[GetEnnupleArchiviazione]
(
 @idSistemaRichiedente UNIQUEIDENTIFIER
,@idUnitaOperativa UNIQUEIDENTIFIER
,@idSistemaErogante UNIQUEIDENTIFIER
)
RETURNS 
    @Result TABLE (
        [GiorniOrdiniCompletati] INT NOT NULL,
        [GiorniOrdiniNoRisposta] INT NOT NULL,
        [GiorniOrdiniPrenotazioniPassate] INT NOT NULL,
        [GiorniOrdiniAltro] INT NOT NULL,
        [GiorniVersioniCompletati] INT NOT NULL,
        [GiorniVersioniPrenotazioniPassate] INT NOT NULL,
        [Peso] INT NOT NULL)
AS
BEGIN
	--
	-- Primo step match completo
	--
	INSERT INTO @Result
	SELECT TOP 1 [GiorniOrdiniCompletati]
		  ,[GiorniOrdiniNoRisposta]
		  ,[GiorniOrdiniPrenotazioniPassate]
		  ,[GiorniOrdiniAltro]
		  ,[GiorniVersioniCompletati]
		  ,[GiorniVersioniPrenotazioniPassate]
		  ,CONVERT(INT, 3) AS [Peso]
	  FROM [dbo].[EnnupleArchiviazione]
	  WHERE [Disabilitato] = 0
		AND ([IdSistemaRichiedente] IS NULL OR [IdSistemaRichiedente] = @IdSistemaRichiedente OR @IdSistemaRichiedente IS NULL)
		AND ([IdUnitaOperativa] IS NULL OR [IdUnitaOperativa] = @IdUnitaOperativa OR @IdUnitaOperativa IS NULL)
		AND ([IdSistemaErogante] IS NULL OR [IdSistemaErogante] = @IdSistemaErogante OR @IdSistemaErogante IS NULL)

		AND NOT [IdSistemaRichiedente] IS NULL
		AND NOT [IdUnitaOperativa] IS NULL
		AND NOT[IdSistemaErogante] IS NULL

	IF NOT EXISTS (SELECT * FROM @Result)
	BEGIN
		--
		-- Secondo step match parziale
		--
		INSERT INTO @Result
		SELECT TOP 1 *
		FROM (
		SELECT MAX([GiorniOrdiniCompletati]) AS [GiorniOrdiniCompletati]
			  ,MAX([GiorniOrdiniNoRisposta]) AS [GiorniOrdiniNoRisposta]
			  ,MAX([GiorniOrdiniPrenotazioniPassate]) AS [GiorniOrdiniPrenotazioniPassate]
			  ,MAX([GiorniOrdiniAltro]) AS [GiorniOrdiniAltro]
			  ,MAX([GiorniVersioniCompletati]) AS [GiorniVersioniCompletati]
			  ,MAX([GiorniVersioniPrenotazioniPassate]) AS [GiorniVersioniPrenotazioniPassate]

			  ,(CASE WHEN [IdSistemaRichiedente] IS NULL THEN 0 ELSE 1 END
				+ CASE WHEN [IdUnitaOperativa] IS NULL THEN 0 ELSE 1 END
				+ CASE WHEN [IdSistemaErogante] IS NULL THEN 0 ELSE 1 END ) AS [Peso]
		 
		  FROM [dbo].[EnnupleArchiviazione]
		  WHERE [Disabilitato] = 0
			AND ([IdSistemaRichiedente] IS NULL OR [IdSistemaRichiedente] = @IdSistemaRichiedente OR @IdSistemaRichiedente IS NULL)
			AND ([IdUnitaOperativa] IS NULL OR [IdUnitaOperativa] = @IdUnitaOperativa OR @IdUnitaOperativa IS NULL)
			AND ([IdSistemaErogante] IS NULL OR [IdSistemaErogante] = @IdSistemaErogante OR @IdSistemaErogante IS NULL)

			AND NOT ([IdSistemaRichiedente] IS NULL	AND [IdUnitaOperativa] IS NULL AND [IdSistemaErogante] IS NULL)
			AND NOT (NOT [IdSistemaRichiedente] IS NULL	AND NOT [IdUnitaOperativa] IS NULL	AND NOT[IdSistemaErogante] IS NULL)

		  GROUP BY (CASE WHEN [IdSistemaRichiedente] IS NULL THEN 0 ELSE 1 END
				+ CASE WHEN [IdUnitaOperativa] IS NULL THEN 0 ELSE 1 END
				+ CASE WHEN [IdSistemaErogante] IS NULL THEN 0 ELSE 1 END )

		) Parziali
		ORDER BY [Peso] DESC

	END

	IF NOT EXISTS (SELECT * FROM @Result)
	BEGIN
		--
		-- Terzo step nessun match ritorno il generico
		--
		INSERT INTO @Result
		SELECT TOP 1 [GiorniOrdiniCompletati]
			  ,[GiorniOrdiniNoRisposta]
			  ,[GiorniOrdiniPrenotazioniPassate]
			  ,[GiorniOrdiniAltro]
			  ,[GiorniVersioniCompletati]
			  ,[GiorniVersioniPrenotazioniPassate]
			  ,CONVERT(INT, 0) AS [Peso]

		  FROM [dbo].[EnnupleArchiviazione]
		  WHERE [Disabilitato] = 0
			AND [IdSistemaRichiedente] IS NULL
			AND [IdUnitaOperativa] IS NULL
			AND [IdSistemaErogante] IS NULL
	END
	
	IF NOT EXISTS (SELECT * FROM @Result)
	BEGIN
		--
		-- Ultimo step nessun generico, uso dei default
		--
		INSERT INTO @Result
		SELECT CONVERT(INT, 30) AS [GiorniOrdiniCompletati]
			  ,CONVERT(INT, 120) AS [GiorniOrdiniNoRisposta]
			  ,CONVERT(INT, 220) AS [GiorniOrdiniPrenotazioniPassate]
			  ,CONVERT(INT, 320) AS [GiorniOrdiniAltro]
			  ,CONVERT(INT, 1) AS [GiorniVersioniCompletati]
			  ,CONVERT(INT, 11) AS [GiorniVersioniPrenotazioniPassate]
			  ,CONVERT(INT, -1) AS [Peso]
	END

	RETURN
END