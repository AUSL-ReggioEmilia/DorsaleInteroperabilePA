

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-02-27
-- Description:	Restituisce gli ultimi arrivi dei referti
-- =============================================
CREATE VIEW [DataAccess].[UltimiArriviReferti] AS
	SELECT AziendaErogante, SistemaErogante, DataArrivo FROM sinottico.UltimiArriviReferti