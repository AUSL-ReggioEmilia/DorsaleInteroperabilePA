-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-12-30
-- Description:	Lista delle relazioni con minore
-- =============================================
CREATE PROCEDURE [pazienti_ws].[ConsensiRelazioniConMinoreLista]
(
	@Identity varchar(64)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
		  Id
		, Descrizione
		, Ordinamento
	FROM 
		dbo.RelazioneConMinore
	ORDER BY 
		Ordinamento
END