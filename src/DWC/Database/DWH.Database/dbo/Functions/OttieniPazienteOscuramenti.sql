



-- =============================================
-- Author:      Alessandro Nostini
-- Create date: 2018-10-25
-- Description: Restituisce i dati di oscuramento del paziente
--				Utilizza la nuova tabella PazientiOscurati
-- =============================================
CREATE FUNCTION [dbo].[OttieniPazienteOscuramenti]
(
	@IdPaziente UNIQUEIDENTIFIER
)
RETURNS TABLE 
AS
RETURN 
(
	--
	-- Mima l'utilizzo diretto della function che restituisce la catena di fusione
	-- Restituisce sempre solo un record
	--
	SELECT 
		CAST(MAX(CAST(OscuraReferti AS TINYINT)) AS BIT) AS OscuraReferti
		, CAST(MAX(CAST(OscuraRicoveri AS TINYINT)) AS BIT) AS OscuraRicoveri
		, CAST(MAX(CAST(OscuraPrescrizioni AS TINYINT)) AS BIT) AS OscuraPrescrizioni
		, CAST(MAX(CAST(OscuraNoteAnamnestiche AS TINYINT)) AS BIT) AS OscuraNoteAnamnestiche

	FROM OscuramentiPazienti AS OP
		INNER JOIN (
			SELECT IdPazienteFuso AS IdPazienti FROM [sac].[PazientiFusioni] WHERE IdPazienti IN ( 
				--Cerco la root della catena di fusione
				SELECT TOP 1
					IdPazienti
				FROM 
					[sac].[PazientiFusioni] 
				WHERE 
					IdPazienteFuso = @IdPaziente --cerca sempre nella colonna dei fusi per ottenere la ROOT
					OR IdPazienti = @IdPaziente --nel caso il parametro sia la ROOT
			)

			UNION ALL
			SELECT TOP 1
				IdPazienti
			FROM 
				[sac].[PazientiFusioni] 
			WHERE 
				IdPazienteFuso = @IdPaziente --nel caso il parametro sia un fuso
				OR IdPazienti = @IdPaziente --nel caso il parametro sia la ROOT

			UNION ALL
			SELECT @IdPaziente --nel caso @IdPaziente non appartenga a catena di fusione
		) AS TAB
			ON OP.IdPaziente = TAB.IdPazienti

)