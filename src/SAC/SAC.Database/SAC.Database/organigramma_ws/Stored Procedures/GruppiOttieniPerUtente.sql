-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-04
-- Description:	Ritorna la lista dei gruppi che contengono l'utente passato
-- =============================================
CREATE PROC [organigramma_ws].[GruppiOttieniPerUtente]
(
 @Utente varchar(128)
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT 		
		G.[Id],
		G.[Gruppo],
		G.[Descrizione],
		G.[Email],
		G.[Attivo]
	FROM 
		[organigramma].[OttieneGruppiPerUtente](@Utente) Gruppi
	INNER JOIN 
		[organigramma_ws].[Gruppi] G ON G.ID = Gruppi.IdFiglio
	ORDER BY 
		G.[Gruppo]
END