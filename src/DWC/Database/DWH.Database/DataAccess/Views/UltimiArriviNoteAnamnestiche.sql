

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-02-27
-- Description:	Restituisce gli ultimi arrivi delle note anamnestiche 
-- =============================================
CREATE VIEW [DataAccess].[UltimiArriviNoteAnamnestiche] AS
	SELECT AziendaErogante, SistemaErogante, DataArrivo FROM sinottico.UltimiArriviNoteAnamnestiche