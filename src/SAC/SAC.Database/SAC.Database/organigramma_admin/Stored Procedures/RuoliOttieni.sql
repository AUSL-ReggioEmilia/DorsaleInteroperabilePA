
-- =============================================
-- Author:      /
-- Create date: /
-- Description: Ottiene di un Ruolo
-- Modify date: 2018-01-19 SimoneB. Restituisce anche le Note
-- =============================================
CREATE PROC [organigramma_admin].[RuoliOttieni]
(
 @ID uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      [ID],
      [Codice],
      [Descrizione],
      [Attivo],
      [DataInserimento],
      [DataModifica],
      [UtenteInserimento],
      [UtenteModifica],
	  [Note]
  FROM  [organigramma].[Ruoli]
  WHERE [ID] = @ID

END

