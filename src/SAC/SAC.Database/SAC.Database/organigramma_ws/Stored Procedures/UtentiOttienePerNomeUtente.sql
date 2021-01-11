-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-08
-- Description:	Ritorna un utente di AD per AccountName
-- =============================================
CREATE PROC [organigramma_ws].[UtentiOttienePerNomeUtente]
(
 @Utente varchar(128)
)
AS
BEGIN
	SET NOCOUNT ON

	--Eseguo query
	SELECT [Id],
		[Utente],
		[Descrizione],
		[Cognome],
		[Nome],
		[CodiceFiscale],
		[Matricola],
		[Email],
		[Attivo]
	FROM  [organigramma_ws].[Utenti]
	WHERE Utente = @Utente
END