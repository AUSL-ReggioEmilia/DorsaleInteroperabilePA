

-- =============================================
-- Author:      SimoneB
-- Create date: 2017-11-28
-- Description: Lista delle note anamnestiche modificate nelle ultime x ore
-- =============================================
CREATE PROCEDURE [dbo].[BevsNoteAnamnesticheUltimiArrivi]
(
 @NumeroOre INT --FILTRA SOLO LE NOTE ANAMNESTICHE MODIFICATE NON PIU' DI TOT ORE FA
)
AS
BEGIN
  SET NOCOUNT OFF

	SET @NumeroOre = @NumeroOre * -1
	
	SELECT 
		  AziendaErogante
		, SistemaErogante
		, MAX(DataModifica) AS DataModifica
		, COUNT(*) AS [Count]
	FROM 
		[store].[NoteAnamnesticheBase]
	WHERE 
		DataModifica > DATEADD(HOUR, @NumeroOre, GETDATE())		
		AND DataPartizione > DATEADD(YEAR, -1, GETDATE()) --LIMITO IL NUMERO DEI DB COINVOLTI

	GROUP BY 
		AziendaErogante, SistemaErogante
	ORDER BY 
		AziendaErogante, SistemaErogante

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsNoteAnamnesticheUltimiArrivi] TO [ExecuteFrontEnd]
    AS [dbo];

