

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-04-20
--
-- Description:	Calcola i valori minimi dei giorni di archivazione
--
-- =============================================
CREATE FUNCTION [dbo].[GetArchiviazioneMinima]
(
)
RETURNS 
    @Result TABLE (
        [GiorniOrdiniCompletati] INT NOT NULL,
        [GiorniOrdiniNoRisposta] INT NOT NULL,
        [GiorniOrdiniPrenotazioniPassate] INT NOT NULL,
        [GiorniOrdiniAltro] INT NOT NULL,
        [GiorniVersioniCompletati] INT NOT NULL,
        [GiorniVersioniPrenotazioniPassate] INT NOT NULL)
AS
BEGIN
	--
	-- Valori minimi
	--
	INSERT INTO @Result
	SELECT 
		   MIN([GiorniOrdiniCompletati])
		  ,MIN([GiorniOrdiniNoRisposta])
		  ,MIN([GiorniOrdiniPrenotazioniPassate])
		  ,MIN([GiorniOrdiniAltro])
		  ,MIN([GiorniVersioniCompletati])
		  ,MIN([GiorniVersioniPrenotazioniPassate])
	  FROM [dbo].[EnnupleArchiviazione]
	  WHERE [Disabilitato] = 0

	RETURN
END