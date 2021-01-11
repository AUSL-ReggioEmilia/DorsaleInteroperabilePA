
-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-04
-- Description:	Ritorna il gruppo di AD
-- =============================================
CREATE PROC [organigramma_ws].[GruppiOttienePerGruppo]
(
 @Gruppo varchar(128)
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		[Id],
		[Gruppo],
		[Descrizione],
		[Email],
		[Attivo]
	FROM [organigramma_ws].[Gruppi]
	WHERE Gruppo = @Gruppo
END