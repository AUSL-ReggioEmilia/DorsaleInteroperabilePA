

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-02-27
-- Description:	Restituisce gli ultimi arrivi delle prescrizioni
-- =============================================
CREATE VIEW [DataAccess].[UltimiArriviPrescrizioni] AS
	SELECT TipoPrescrizione, DataArrivo FROM sinottico.UltimiArriviPrescrizioni