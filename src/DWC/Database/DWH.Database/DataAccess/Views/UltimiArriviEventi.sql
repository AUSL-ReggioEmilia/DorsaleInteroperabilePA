

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-02-27
-- Description:	Restituisce gli ultimi arrivi degli eventi
-- =============================================
CREATE VIEW [DataAccess].[UltimiArriviEventi] AS
	SELECT AziendaErogante, SistemaErogante, DataArrivo FROM sinottico.UltimiArriviEventi