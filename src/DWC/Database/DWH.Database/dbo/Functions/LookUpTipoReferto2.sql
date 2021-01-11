


-- =============================================
-- Author:		Simone B
-- Create date: 2017-07-11
-- Description:	Lookup tipi referto + AziendaErogante.
-- Modify date: 2019-02-07 - ETTORE: Aggiunto replace della stringa '[RefertoSingolo]' con ''  
--									Per gestione dei referti singoli tramite la tabella dbo.Tipireferto
--									Un referto singolo viene marcato tramite la stringa '[RefertoSingolo]'
--									nella descrizione del tiporeferto e tale stringa deve essere poi rimossa 
--									Modifica TEMPORANEA; da togliere quando alla tabella dbo.Tipireferto
--									sarà aggiunto il campo flag RefertoSingolo e il campo RepartiEroganti
-- =============================================
CREATE FUNCTION [dbo].[LookUpTipoReferto2]
(	
	@AziendaErogante VARCHAR(16)
	, @SistemaErogante VARCHAR(16)
	, @SpecialitaErogante VARCHAR(64)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP 1 
		Id, REPLACE(Descrizione, '[RefertoSingolo]', '') AS Descrizione
		, SistemaErogante, SpecialitaErogante
	FROM dbo.TipiReferto
	WHERE 
		(SistemaErogante = @SistemaErogante
		AND (AziendaErogante = @AziendaErogante)
		AND (
				SpecialitaErogante = @SpecialitaErogante 
				OR 
				SpecialitaErogante IS NULL
			)
		)
		OR
		(SistemaErogante = 'Altro')
		
		
	ORDER BY CASE 
		WHEN SistemaErogante = 'Altro' THEN 1 ELSE 0 END ASC
            , SpecialitaErogante DESC

)