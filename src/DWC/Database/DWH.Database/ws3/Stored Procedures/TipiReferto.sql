




-- =============================================
-- Author:		Ettore
-- Create date: 2016-04-26
-- Description:	Restituisce i "Tipi di referto"
-- Modify date: 2017-07-11: aggiunto l'azienda erogante
-- =============================================
CREATE PROCEDURE [ws3].[TipiReferto]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		Id
		, AziendaErogante
		, SistemaErogante
		, SpecialitaErogante
		, Descrizione
		, Icona
	FROM 
		dbo.TipiReferto
	ORDER BY Ordinamento
END