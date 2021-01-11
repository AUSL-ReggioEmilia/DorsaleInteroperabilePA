

CREATE PROC [organigramma_admin].[UnitaOperativeOttieni]
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
      [CodiceAzienda],
      [Attivo],
      [DataInserimento],
      [DataModifica],
      [UtenteInserimento],
      [UtenteModifica]
  FROM  [organigramma].[UnitaOperative]
  WHERE [ID] = @ID

END
